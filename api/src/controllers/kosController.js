import { KosModel } from "../models/kosModel.js";

export const KosController = {
  async getAll(req, res) {
    try {
      const data = await KosModel.getAll(req.query);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  async getById(req, res) {
    try {
      const data = await KosModel.getById(req.params.id);
      res.json(data);
    } catch (err) {
      res.status(404).json({ error: err.message });
    }
  },

  // POST /api/kos  (khusus pemilik) -> iklan dicatat atas nama akun ini
  async create(req, res) {
    try {
      const payload = { ...req.body, owner_id: req.user.id };
      delete payload.id;
      const data = await KosModel.create(payload);
      res.status(201).json(data);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  // PUT /api/kos/:id  (hanya pemilik iklan ini)
  async update(req, res) {
    try {
      const ownerId = await KosModel.getOwnerId(req.params.id);
      if (ownerId === undefined) {
        return res.status(404).json({ error: "Data tidak ditemukan" });
      }
      if (ownerId !== req.user.id) {
        return res
          .status(403)
          .json({ error: "Kamu hanya bisa mengubah iklan milikmu sendiri" });
      }
      const payload = { ...req.body };
      delete payload.id;
      delete payload.owner_id; // pemilik iklan tidak bisa dipindah
      const data = await KosModel.update(req.params.id, payload);
      res.json(data);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  // DELETE /api/kos/:id  (hanya pemilik iklan ini)
  async remove(req, res) {
    try {
      const ownerId = await KosModel.getOwnerId(req.params.id);
      if (ownerId === undefined) {
        return res.status(404).json({ error: "Data tidak ditemukan" });
      }
      if (ownerId !== req.user.id) {
        return res
          .status(403)
          .json({ error: "Kamu hanya bisa menghapus iklan milikmu sendiri" });
      }
      const result = await KosModel.remove(req.params.id);
      res.json(result);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },
};
