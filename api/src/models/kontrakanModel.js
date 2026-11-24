import { supabase } from "../config/supabaseClient.js";

const SELECT_WITH_AREA = "*, area:areas(id, name)";

// Pilihan urutan: ?sort=termurah | termahal | terdekat
const SORT_OPTIONS = {
  termurah: { column: "price_per_year", ascending: true },
  termahal: { column: "price_per_year", ascending: false },
  terdekat: { column: "distance_km", ascending: true },
};

export const KontrakanModel = {
  // Filter opsional: ?area_id=...&available=true&search=griya&sort=terdekat
  async getAll({ area_id, available, search, sort } = {}) {
    const order = SORT_OPTIONS[sort] || SORT_OPTIONS.termurah;
    let query = supabase
      .from("kontrakan")
      .select(SELECT_WITH_AREA)
      .order(order.column, { ascending: order.ascending });

    if (area_id) query = query.eq("area_id", area_id);
    if (available !== undefined) query = query.eq("is_available", available === "true");
    if (search) query = query.ilike("name", `%${search}%`);

    const { data, error } = await query;
    if (error) throw error;
    return data;
  },

  async getById(id) {
    const { data, error } = await supabase
      .from("kontrakan")
      .select(SELECT_WITH_AREA)
      .eq("id", id)
      .single();
    if (error) throw error;
    return data;
  },

  async create(payload) {
    const { data, error } = await supabase
      .from("kontrakan")
      .insert([payload])
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from("kontrakan")
      .update(payload)
      .eq("id", id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async remove(id) {
    const { error } = await supabase.from("kontrakan").delete().eq("id", id);
    if (error) throw error;
    // Hapus juga dari daftar favorit semua user
    await supabase
      .from("favorites")
      .delete()
      .eq("item_type", "kontrakan")
      .eq("item_id", id);
    return { message: "Kontrakan deleted successfully" };
  },
};