import express from "express";
import { AreaController } from "../controllers/areaController.js";

const router = express.Router();

router.get("/", AreaController.getAll);
router.get("/:id", AreaController.getById);
router.post("/", AreaController.create);
router.put("/:id", AreaController.update);
router.delete("/:id", AreaController.remove);

export default router;