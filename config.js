/* ============================================================================
   PHOENIX HOLIDAYS — the only file you ever need to edit by hand.
   ============================================================================

   Fill in the two values below ONCE, from your Supabase dashboard:
     Supabase -> Project Settings -> API
       "Project URL"        -> SUPABASE_URL
       "anon" / "public" key -> SUPABASE_ANON_KEY

   The anon key is SAFE to put here. It is designed to be public — the
   database rules (RLS) are what protect your data, not this key.
   NEVER paste the "service_role" key here. That one is a master key.
   ============================================================================ */

window.PHOENIX_CONFIG = {

  SUPABASE_URL:      "https://vojyumeyovynwnlrixyu.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvanl1bWV5b3Z5bndubHJpeHl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1NjU3ODQsImV4cCI6MjEwMjE0MTc4NH0.l1K_jVXDEtCURk_6whzppfzFC8nJxGn0LXXpmENPSgw",

  /* Fallback WhatsApp number, used only if the database can't be reached.
     Country code + number, digits only. */
  WA_FALLBACK: "201224741570",

  /* Photo compression before upload — keeps the site fast on mobile data
     and keeps you inside the free storage tier. */
  PHOTO_MAX_WIDTH: 1600,
  PHOTO_QUALITY:   0.82
};
