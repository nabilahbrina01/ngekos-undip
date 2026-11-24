import express from "express";
import { AreaController } from "../controllers/areaController.js";
import { requireAuth } from "../middleware/authMiddleware.js";
import { requirePemilik } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get("/", AreaController.getAll);
router.get("/:id", AreaController.getById);
// Tambah, ubah, dan hapus area: wajib login sebagai pemilik kos
router.post("/", requireAuth, requirePemilik, AreaController.create);
router.put("/:id", requireAuth, requirePemilik, AreaController.update);
router.delete("/:id", requireAuth, requirePemilik, AreaController.remove);

export default router;