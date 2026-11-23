import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserModel } from "../models/userModel.js";

// Membuat token JWT yang berlaku 7 hari
function createToken(user) {
  return jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
}

export const AuthController = {
  // POST /api/auth/register  body: { name, email, password }
  async register(req, res) {
    try {
      const name = (req.body.name || "").trim();
      const email = (req.body.email || "").trim().toLowerCase();
      const password = req.body.password || "";

      if (!name || !email || !password) {
        return res.status(400).json({ error: "Nama, email, dan password wajib diisi" });
      }
      if (password.length < 6) {
        return res.status(400).json({ error: "Password minimal 6 karakter" });
      }

      const existing = await UserModel.findByEmail(email);
      if (existing) {
        return res.status(409).json({ error: "Email sudah terdaftar" });
      }

      // Password disimpan dalam bentuk hash, bukan teks asli
      const password_hash = await bcrypt.hash(password, 10);
      const user = await UserModel.create({ name, email, password_hash });

      res.status(201).json({ token: createToken(user), user });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/login  body: { email, password }
  async login(req, res) {
    try {
      const email = (req.body.email || "").trim().toLowerCase();
      const password = req.body.password || "";

      if (!email || !password) {
        return res.status(400).json({ error: "Email dan password wajib diisi" });
      }

      const user = await UserModel.findByEmail(email);
      const valid = user && (await bcrypt.compare(password, user.password_hash));
      if (!valid) {
        return res.status(401).json({ error: "Email atau password salah" });
      }

      const { password_hash, ...publicUser } = user;
      res.json({ token: createToken(user), user: publicUser });
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