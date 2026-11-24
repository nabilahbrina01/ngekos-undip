import crypto from "crypto";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserModel } from "../models/userModel.js";
import { OtpModel } from "../models/otpModel.js";
import { sendOtpEmail } from "../config/mailer.js";

const OTP_TTL_MINUTES = 1; // kode berlaku 1 menit
const OTP_MAX_ATTEMPTS = 3; // maksimal 3 kali salah memasukkan kode
const RESEND_COOLDOWN_SECONDS = 60; // jeda minimal kirim ulang kode

// Membuat token JWT yang berlaku 7 hari
function createToken(user) {
  return jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
}

function cleanEmail(value) {
  return (value || "").trim().toLowerCase();
}

// Kode OTP disimpan dalam bentuk hash, bukan angka aslinya
function hashCode(code) {
  return crypto
    .createHmac("sha256", process.env.JWT_SECRET)
    .update(code)
    .digest("hex");
}

// Buat kode 6 digit, simpan, lalu kirim ke email
async function issueOtp(email, purpose) {
  const code = crypto.randomInt(0, 1000000).toString().padStart(6, "0");
  await OtpModel.create({
    email,
    purpose,
    code_hash: hashCode(code),
    expires_at: new Date(Date.now() + OTP_TTL_MINUTES * 60 * 1000).toISOString(),
  });
  await sendOtpEmail(email, code, purpose);
}

// Sisa detik sebelum boleh kirim ulang (0 = boleh kirim sekarang)
async function cooldownLeft(email, purpose) {
  const latest = await OtpModel.findLatest(email, purpose);
  if (!latest) return 0;
  const passed = (Date.now() - new Date(latest.created_at).getTime()) / 1000;
  return Math.max(0, Math.ceil(RESEND_COOLDOWN_SECONDS - passed));
}

// Cek kode OTP. Mengembalikan pesan error, atau null jika benar.
async function checkOtp(email, purpose, code) {
  const otp = await OtpModel.findLatest(email, purpose);
  if (!otp) return "Kode OTP tidak ditemukan, silakan minta kode baru";
  if (new Date(otp.expires_at) < new Date()) {
    return "Kode OTP sudah kedaluwarsa, silakan minta kode baru";
  }
  if (otp.attempts >= OTP_MAX_ATTEMPTS) {
    return "Terlalu banyak percobaan, silakan minta kode baru";
  }
  if (otp.code_hash !== hashCode(code)) {
    await OtpModel.setAttempts(otp.id, otp.attempts + 1);
    return "Kode OTP salah";
  }
  await OtpModel.remove(email, purpose); // kode hanya bisa dipakai sekali
  return null;
}

export const AuthController = {
  // POST /api/auth/register  body: { name, email, password, role }
  // role: "pencari" (default) atau "pemilik"
  // Akun dibuat dalam status belum terverifikasi, lalu kode OTP dikirim ke email.
  async register(req, res) {
    try {
      const name = (req.body.name || "").trim();
      const email = cleanEmail(req.body.email);
      const password = req.body.password || "";
      const role = req.body.role === "pemilik" ? "pemilik" : "pencari";

      if (!name || !email || !password) {
        return res.status(400).json({ error: "Nama, email, dan password wajib diisi" });
      }
      if (password.length < 6) {
        return res.status(400).json({ error: "Password minimal 6 karakter" });
      }

      // Password disimpan dalam bentuk hash, bukan teks asli
      const password_hash = await bcrypt.hash(password, 10);
      const existing = await UserModel.findByEmail(email);

      if (existing && existing.is_verified) {
        return res.status(409).json({ error: "Email sudah terdaftar" });
      }
      if (existing) {
        // Pernah daftar tapi belum verifikasi: perbarui data lalu kirim kode baru
        await UserModel.updateByEmail(email, { name, password_hash, role });
      } else {
        await UserModel.create({ name, email, password_hash, role });
      }

      await issueOtp(email, "register");
      res.status(201).json({
        message: "Kode OTP telah dikirim ke email kamu",
        email,
      });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/verify-otp  body: { email, code }
  // Kode benar = akun terverifikasi dan langsung login.
  async verifyOtp(req, res) {
    try {
      const email = cleanEmail(req.body.email);
      const code = (req.body.code || "").trim();
      if (!email || !code) {
        return res.status(400).json({ error: "Email dan kode OTP wajib diisi" });
      }

      const error = await checkOtp(email, "register", code);
      if (error) return res.status(400).json({ error });

      const user = await UserModel.updateByEmail(email, { is_verified: true });
      res.json({ token: createToken(user), user });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/resend-otp  body: { email, purpose: "register" | "reset" }
  async resendOtp(req, res) {
    try {
      const email = cleanEmail(req.body.email);
      const purpose = req.body.purpose === "reset" ? "reset" : "register";

      const user = await UserModel.findByEmail(email);
      if (!user || (purpose === "register" && user.is_verified)) {
        return res.status(400).json({ error: "Tidak ada kode yang perlu dikirim ulang" });
      }

      const wait = await cooldownLeft(email, purpose);
      if (wait > 0) {
        return res
          .status(429)
          .json({ error: `Tunggu ${wait} detik sebelum kirim ulang kode` });
      }

      await issueOtp(email, purpose);
      res.json({ message: "Kode OTP baru telah dikirim" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/login  body: { email, password }
  async login(req, res) {
    try {
      const email = cleanEmail(req.body.email);
      const password = req.body.password || "";

      if (!email || !password) {
        return res.status(400).json({ error: "Email dan password wajib diisi" });
      }

      const user = await UserModel.findByEmail(email);
      const valid = user && (await bcrypt.compare(password, user.password_hash));
      if (!valid) {
        return res.status(401).json({ error: "Email atau password salah" });
      }

      // Belum verifikasi: kirim kode baru (jika sudah lewat jeda), lalu minta OTP
      if (!user.is_verified) {
        if ((await cooldownLeft(email, "register")) === 0) {
          await issueOtp(email, "register");
        }
        return res.status(403).json({
          error: "Email belum diverifikasi. Kode OTP telah dikirim ke email kamu",
          needsVerification: true,
          email,
        });
      }

      const { password_hash, ...publicUser } = user;
      res.json({ token: createToken(user), user: publicUser });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/forgot-password  body: { email }
  async forgotPassword(req, res) {
    try {
      const email = cleanEmail(req.body.email);
      if (!email) {
        return res.status(400).json({ error: "Email wajib diisi" });
      }

      const user = await UserModel.findByEmail(email);
      if (!user) {
        return res.status(404).json({ error: "Email belum terdaftar" });
      }

      const wait = await cooldownLeft(email, "reset");
      if (wait > 0) {
        return res
          .status(429)
          .json({ error: `Tunggu ${wait} detik sebelum kirim ulang kode` });
      }

      await issueOtp(email, "reset");
      res.json({ message: "Kode OTP telah dikirim ke email kamu" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/reset-password  body: { email, code, password }
  async resetPassword(req, res) {
    try {
      const email = cleanEmail(req.body.email);
      const code = (req.body.code || "").trim();
      const password = req.body.password || "";

      if (!email || !code || !password) {
        return res
          .status(400)
          .json({ error: "Email, kode OTP, dan password baru wajib diisi" });
      }
      if (password.length < 6) {
        return res.status(400).json({ error: "Password minimal 6 karakter" });
      }

      const error = await checkOtp(email, "reset", code);
      if (error) return res.status(400).json({ error });

      // Reset lewat email juga membuktikan email ini milik user
      const password_hash = await bcrypt.hash(password, 10);
      await UserModel.updateByEmail(email, { password_hash, is_verified: true });
      res.json({ message: "Password berhasil diubah, silakan masuk" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // GET /api/auth/me  header: Authorization: Bearer <token>
  async me(req, res) {
    try {
      const user = await UserModel.findById(req.user.id);
      if (!user) {
        return res.status(404).json({ error: "User tidak ditemukan" });
      }
      res.json(user);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
};