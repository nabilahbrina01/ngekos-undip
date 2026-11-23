import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import areaRoutes from "./routes/areaRoutes.js";
import kosRoutes from "./routes/kosRoutes.js";
import kontrakanRoutes from "./routes/kontrakanRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import favoriteRoutes from "./routes/favoriteRoutes.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    name: "NgekosUndip API",
    status: "running",
    endpoints: ["/api/auth", "/api/areas", "/api/kos", "/api/kontrakan", "/api/favorites"],
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/areas", areaRoutes);
app.use("/api/kos", kosRoutes);
app.use("/api/kontrakan", kontrakanRoutes);
app.use("/api/favorites", favoriteRoutes);

// Di Vercel server dijalankan otomatis, jadi listen hanya saat di laptop
if (!process.env.VERCEL) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

export default app;