import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import areaRoutes from "./routes/areaRoutes.js";
import kosRoutes from "./routes/kosRoutes.js";
import kontrakanRoutes from "./routes/kontrakanRoutes.js";
import authRoutes from "./routes/authRoutes.js"; // BARU

dotenv.config();

const app = express();
app.use(cors()); // supaya bisa diakses juga dari Flutter Web / browser
app.use(express.json());

// Halaman cek: buka URL Vercel kamu di browser, harus muncul JSON ini
app.get("/", (req, res) => {
  res.json({
    name: "NgekosUndip API",
    status: "running",
    endpoints: ["/api/auth", "/api/areas", "/api/kos", "/api/kontrakan"], // BARU
  });
});

app.use("/api/auth", authRoutes); // BARU
app.use("/api/areas", areaRoutes);
app.use("/api/kos", kosRoutes);
app.use("/api/kontrakan", kontrakanRoutes);

// Di Vercel server dijalankan otomatis, jadi listen hanya saat di laptop
if (!process.env.VERCEL) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

export default app;