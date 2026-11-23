import { supabase } from "../config/supabaseClient.js";

// Kolom yang aman dikirim ke aplikasi (password_hash TIDAK ikut)
const PUBLIC_COLUMNS = "id, name, email, created_at";

export const UserModel = {
  // Dipakai saat login: butuh password_hash untuk dicocokkan
  async findByEmail(email) {
    const { data, error } = await supabase
      .from("users")
      .select("*")
      .eq("email", email)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  async findById(id) {
    const { data, error } = await supabase
      .from("users")
      .select(PUBLIC_COLUMNS)
      .eq("id", id)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  async create({ name, email, password_hash }) {
    const { data, error } = await supabase
      .from("users")
      .insert([{ name, email, password_hash }])
      .select(PUBLIC_COLUMNS)
      .single();
    if (error) throw error;
    return data;
  },
};