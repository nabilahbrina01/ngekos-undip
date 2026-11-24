import express from "express";
import { KontrakanController } from "../controllers/kontrakanController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", KontrakanController.getAll);
router.get("/:id", KontrakanController.getById);
// Tambah, ubah, dan hapus data wajib login (token)
router.post("/", requireAuth, KontrakanController.create);
router.put("/:id", requireAuth, KontrakanController.update);
router.delete("/:id", requireAuth, KontrakanController.remove);

export default router;