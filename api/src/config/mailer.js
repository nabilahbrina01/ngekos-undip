import nodemailer from "nodemailer";

// Kirim email lewat Gmail memakai App Password (bukan password Gmail biasa)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

const SUBJECTS = {
  register: "Kode verifikasi akun NgekosUndip",
  reset: "Kode reset password NgekosUndip",
};

const INTROS = {
  register: "Gunakan kode berikut untuk memverifikasi akun NgekosUndip kamu:",
  reset: "Gunakan kode berikut untuk membuat password baru akun NgekosUndip kamu:",
};

export async function sendOtpEmail(to, code, purpose) {
  await transporter.sendMail({
    from: `"NgekosUndip" <${process.env.GMAIL_USER}>`,
    to,
    subject: SUBJECTS[purpose],
    text: `${INTROS[purpose]} ${code}\n\nKode berlaku 1 menit. Abaikan email ini jika kamu tidak memintanya.`,
    html: `
      <div style="font-family:Arial,sans-serif;max-width:420px;margin:auto;padding:24px;border:1px solid #E3E7EF;border-radius:16px">
        <h2 style="color:#0B2A4A;margin:0 0 8px">NgekosUndip</h2>
        <p style="color:#374151">${INTROS[purpose]}</p>
        <div style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#0B2A4A;background:#FFF4D6;padding:16px;text-align:center;border-radius:12px">${code}</div>
        <p style="color:#6B7280;font-size:13px">Kode berlaku 1 menit. Abaikan email ini jika kamu tidak memintanya.</p>
      </div>`,
  });
}