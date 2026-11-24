import express from "express";
import { AreaController } from "../controllers/areaController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", AreaController.getAll);
router.get("/:id", AreaController.getById);
// Tambah, ubah, dan hapus data wajib login (token)
router.post("/", requireAuth, AreaController.create);
router.put("/:id", requireAuth, AreaController.update);
router.delete("/:id", requireAuth, AreaController.remove);

export default router;