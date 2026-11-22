import express from "express";
import { KontrakanController } from "../controllers/kontrakanController.js";

const router = express.Router();

router.get("/", KontrakanController.getAll);
router.get("/:id", KontrakanController.getById);
router.post("/", KontrakanController.create);
router.put("/:id", KontrakanController.update);
router.delete("/:id", KontrakanController.remove);

export default router;