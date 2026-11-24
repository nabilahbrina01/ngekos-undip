import express from "express";
import { KosController } from "../controllers/kosController.js";
import { requireAuth } from "../middleware/authMiddleware.js";
import { requirePemilik } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get("/", KosController.getAll);
router.get("/:id", KosController.getById);
// Tambah, ubah, dan hapus: wajib login sebagai pemilik kos.
// Ubah/hapus juga dicek di controller: hanya iklan milik sendiri.
router.post("/", requireAuth, requirePemilik, KosController.create);
router.put("/:id", requireAuth, requirePemilik, KosController.update);
router.delete("/:id", requireAuth, requirePemilik, KosController.remove);

export default router;