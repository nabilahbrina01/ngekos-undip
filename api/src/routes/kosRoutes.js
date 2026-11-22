import express from "express";
import { KosController } from "../controllers/kosController.js";

const router = express.Router();

router.get("/", KosController.getAll);
router.get("/:id", KosController.getById);
router.post("/", KosController.create);
router.put("/:id", KosController.update);
router.delete("/:id", KosController.remove);

export default router;