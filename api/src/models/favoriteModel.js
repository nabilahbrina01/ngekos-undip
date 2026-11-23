import { supabase } from "../config/supabaseClient.js";

export const FavoriteModel = {
  // Semua favorit milik satu user
  async getByUser(userId) {
    const { data, error } = await supabase
      .from("favorites")
      .select("item_type, item_id, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });
    if (error) throw error;
    return data;
  },

  // Tambah favorit (jika sudah ada, tidak dobel)
  async add(userId, itemType, itemId) {
    const { error } = await supabase
      .from("favorites")
      .upsert([{ user_id: userId, item_type: itemType, item_id: itemId }], {
        onConflict: "user_id,item_type,item_id",
        ignoreDuplicates: true,
      });
    if (error) throw error;
    return { item_type: itemType, item_id: itemId };
  },

  async remove(userId, itemType, itemId) {
    const { error } = await supabase
      .from("favorites")
      .delete()
      .eq("user_id", userId)
      .eq("item_type", itemType)
      .eq("item_id", itemId);
    if (error) throw error;
    return { message: "Favorit dihapus" };
  },
};