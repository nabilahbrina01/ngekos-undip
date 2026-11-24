import { KontrakanModel } from "../models/kontrakanModel.js";

export const KontrakanController = {
  async getAll(req, res) {
    try {
      const data = await KontrakanModel.getAll(req.query);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },

  async getById(req, res) {
    try {
      const data = await KontrakanModel.getById(req.params.id);
      res.json(data);
    } catch (err) {
      res.status(404).json({ error: err.message });
    }
  },

  // POST /api/kontrakan  (khusus pemilik) -> iklan dicatat atas nama akun ini
  async create(req, res) {
    try {
      const payload = { ...req.body, owner_id: req.user.id };
      delete payload.id;
      const data = await KontrakanModel.create(payload);
      res.status(201).json(data);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  // PUT /api/kontrakan/:id  (hanya pemilik iklan ini)
  async update(req, res) {
    try {
      const ownerId = await KontrakanModel.getOwnerId(req.params.id);
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
      const data = await KontrakanModel.update(req.params.id, payload);
      res.json(data);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  // DELETE /api/kontrakan/:id  (hanya pemilik iklan ini)
  async remove(req, res) {
    try {
      const ownerId = await KontrakanModel.getOwnerId(req.params.id);
      if (ownerId === undefined) {
        return res.status(404).json({ error: "Data tidak ditemukan" });
      }
      if (ownerId !== req.user.id) {
        return res
          .status(403)
          .json({ error: "Kamu hanya bisa menghapus iklan milikmu sendiri" });
      }
      const result = await KontrakanModel.remove(req.params.id);
      res.json(result);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },
};
