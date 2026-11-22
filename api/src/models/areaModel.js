import { supabase } from "../config/supabaseClient.js";

export const AreaModel = {
  async getAll() {
    const { data, error } = await supabase
      .from("areas")
      .select("*")
      .order("distance_km", { ascending: true });
    if (error) throw error;
    return data;
  },

  async getById(id) {
    const { data, error } = await supabase
      .from("areas")
      .select("*")
      .eq("id", id)
      .single();
    if (error) throw error;
    return data;
  },

  async create(payload) {
    const { data, error } = await supabase
      .from("areas")
      .insert([payload])
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async update(id, payload) {
    const { data, error } = await supabase
      .from("areas")
      .update(payload)
      .eq("id", id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  async remove(id) {
    const { error } = await supabase.from("areas").delete().eq("id", id);
    if (error) throw error;
    return { message: "Area deleted successfully" };
  },
};