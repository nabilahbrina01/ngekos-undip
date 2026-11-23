import express from "express";
import { AuthController } from "../controllers/authController.js";
import { requireAuth } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/register", AuthController.register);
router.post("/login", AuthController.login);
router.post("/verify-otp", AuthController.verifyOtp);
router.post("/resend-otp", AuthController.resendOtp);
router.post("/forgot-password", AuthController.forgotPassword);
router.post("/reset-password", AuthController.resetPassword);
router.get("/me", requireAuth, AuthController.me);

export default router;