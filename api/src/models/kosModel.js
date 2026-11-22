import { supabase } from "../config/supabaseClient.js";

// "area:areas(id, name)" = ikut ambil data area (relasi foreign key area_id)
const SELECT_WITH_AREA = "*, area:areas(id, name)";

export const KosModel = {
  // Filter opsional: ?area_id=...&type=putri&search=melati
  async getAll({ area_id, type, search } = {}) {
    let query = supabase
      .from("kos")
      .select(SELECT_WITH_AREA)
      .order("price_per_month", { ascending: true });

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