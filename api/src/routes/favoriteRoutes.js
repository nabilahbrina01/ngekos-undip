import express from "express";
import { FavoriteController } from "../controllers/favoriteController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const router = express.Router();

// Semua endpoint favorit wajib login (header Authorization: Bearer <token>)
router.use(requireAuth);

router.get("/", FavoriteController.getAll);
router.post("/", FavoriteController.add);
router.delete("/:type/:id", FavoriteController.remove);

export default router;