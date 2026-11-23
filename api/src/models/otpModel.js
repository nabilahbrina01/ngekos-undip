import { supabase } from "../config/supabaseClient.js";

export const OtpModel = {
  // Simpan kode baru (kode lama untuk email + keperluan yang sama dihapus)
  async create({ email, purpose, code_hash, expires_at }) {
    await this.remove(email, purpose);
    const { error } = await supabase
      .from("otp_codes")
      .insert([{ email, purpose, code_hash, expires_at }]);
    if (error) throw error;
  },

  async findLatest(email, purpose) {
    const { data, error } = await supabase
      .from("otp_codes")
      .select("*")
      .eq("email", email)
      .eq("purpose", purpose)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  async setAttempts(id, attempts) {
    const { error } = await supabase
      .from("otp_codes")
      .update({ attempts })
      .eq("id", id);
    if (error) throw error;
  },

  async remove(email, purpose) {
    const { error } = await supabase
      .from("otp_codes")
      .delete()
      .eq("email", email)
      .eq("purpose", purpose);
    if (error) throw error;
  },
};