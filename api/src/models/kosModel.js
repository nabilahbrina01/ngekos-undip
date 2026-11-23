import { supabase } from "../config/supabaseClient.js";

// "area:areas(id, name)" = ikut ambil data area (relasi foreign key area_id)
const SELECT_WITH_AREA = "*, area:areas(id, name)";

// Pilihan urutan: ?sort=termurah | termahal | terdekat
const SORT_OPTIONS = {
  termurah: { column: "price_per_month", ascending: true },
  termahal: { column: "price_per_month", ascending: false },
  terdekat: { column: "distance_km", ascending: true },
};

export const KosModel = {
  // Filter opsional: ?area_id=...&type=putri&search=melati&sort=terdekat
  async getAll({ area_id, type, search, sort } = {}) {
    const order = SORT_OPTIONS[sort] || SORT_OPTIONS.termurah;
    let query = supabase
      .from("kos")
      .select(SELECT_WITH_AREA)
      .order(order.column, { ascending: order.ascending });

    if (area_id) query = query.eq("area_id", area_id);
    if (type) query = query.eq("type", type);
    if (search) query = query.ilike("name", `%${search}%`);

    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  async getById(id) {
    const { data, error } = await supabase
      .from("kos")
      .select(SELECT_WITH_AREA)
      .eq("id", id)
      .single();
    if (error) throw error;
    return data;
  },

  async create(payload) {
    const { data, error } = await supabase
      .from("kos")
      .insert([payload])
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from("kos")
      .update(payload)
      .eq("id", id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async remove(id) {
    const { error } = await supabase.from("kos").delete().eq("id", id);
    if (error) throw error;
    return { message: "Kos deleted successfully" };
  },
};