import jwt from "jsonwebtoken";

// Mengecek header "Authorization: Bearer <token>".
// Jika token valid, data user (id & email) disimpan di req.user.
export function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: "Token tidak ditemukan, silakan login" });
  }

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (err) {
    return res.status(401).json({ error: "Token tidak valid atau sudah kedaluwarsa" });
  }
}