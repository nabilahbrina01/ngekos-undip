import { FavoriteModel } from "../models/favoriteModel.js";

const TYPES = ["kos", "kontrakan"];

export const FavoriteController = {
  // GET /api/favorites
  async getAll(req, res) {
    try {
      const data = await FavoriteModel.getByUser(req.user.id);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  // POST /api/favorites  body: { "item_type": "kos", "item_id": "<uuid>" }
  async add(req, res) {
    const { item_type, item_id } = req.body;
    if (!TYPES.includes(item_type) || !item_id) {
      return res
        .status(400)
        .json({ error: "item_type (kos/kontrakan) dan item_id wajib diisi" });
    }
    try {
      const data = await FavoriteModel.add(req.user.id, item_type, item_id);
      res.status(201).json(data);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  // DELETE /api/favorites/:type/:id
  async remove(req, res) {
    const { type, id } = req.params;
    if (!TYPES.includes(type)) {
      return res.status(400).json({ error: "Tipe harus kos atau kontrakan" });
    }
    try {
      const result = await FavoriteModel.remove(req.user.id, type, id);
      res.json(result);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },
};