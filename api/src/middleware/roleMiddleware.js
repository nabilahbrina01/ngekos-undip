import { UserModel } from "../models/userModel.js";

// Hanya akun dengan role "pemilik" yang boleh lanjut.
// Dipakai SETELAH requireAuth (butuh req.user dari token).
export async function requirePemilik(req, res, next) {
  try {
    const user = await UserModel.findById(req.user.id);
    if (!user || user.role !== "pemilik") {
      return res
        .status(403)
        .json({ error: "Hanya akun pemilik kos yang bisa mengelola iklan" });
    }
    req.user.role = user.role;
    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
