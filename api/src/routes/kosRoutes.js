import express from "express";
import { KosController } from "../controllers/kosController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", KosController.getAll);
router.get("/:id", KosController.getById);
// Tambah, ubah, dan hapus data wajib login (token)
router.post("/", requireAuth, KosController.create);
router.put("/:id", requireAuth, KosController.update);
router.delete("/:id", requireAuth, KosController.remove);

export default router;