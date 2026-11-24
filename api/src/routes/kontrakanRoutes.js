import express from "express";
import { KontrakanController } from "../controllers/kontrakanController.js";
import { requireAuth } from "../middleware/authMiddleware.js";
import { requirePemilik } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get("/", KontrakanController.getAll);
router.get("/:id", KontrakanController.getById);
// Tambah, ubah, dan hapus: wajib login sebagai pemilik kos.
// Ubah/hapus juga dicek di controller: hanya iklan milik sendiri.
router.post("/", requireAuth, requirePemilik, KontrakanController.create);
router.put("/:id", requireAuth, requirePemilik, KontrakanController.update);
router.delete("/:id", requireAuth, requirePemilik, KontrakanController.remove);

export default router;