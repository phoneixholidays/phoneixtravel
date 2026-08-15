/* ============================================================================
   PHOENIX HOLIDAYS — shared reference data + Supabase helper
   Used by both the public site (index.html) and the dashboard (/admin).
   You normally never need to edit this file. To add a new destination or a
   new facility, add one line to the matching list below.
   ============================================================================ */

const CITIES = [
  { key: "hurghada",    ar: "الغردقة",       en: "Hurghada" },
  { key: "sharm",       ar: "شرم الشيخ",     en: "Sharm El Sheikh" },
  { key: "marsaalam",   ar: "مرسى علم",      en: "Marsa Alam" },
  { key: "sahlhasheesh",ar: "سهل حشيش",      en: "Sahl Hasheesh" },
  { key: "elgouna",     ar: "الجونة",        en: "El Gouna" },
  { key: "makadi",      ar: "مكادي باي",     en: "Makadi Bay" },
  { key: "somabay",     ar: "سوما باي",      en: "Soma Bay" },
  { key: "dahab",       ar: "دهب",           en: "Dahab" },
  { key: "sokhna",      ar: "العين السخنة",  en: "Ain Sokhna" },
  { key: "other",       ar: "وجهات أخرى",    en: "Other destinations" }
];

const BOARDS = [
  { key: "UAI", ar: "ألترا شامل كلياً",   en: "Ultra All Inclusive" },
  { key: "AI",  ar: "شامل جميع الوجبات",  en: "All Inclusive" },
  { key: "HB",  ar: "إفطار وعشاء",        en: "Half Board" },
  { key: "BB",  ar: "إفطار فقط",          en: "Bed & Breakfast" },
  { key: "RO",  ar: "إقامة فقط",          en: "Room Only" }
];

const FEATURES = [
  { key: "beach",    ar: "شاطئ خاص",     en: "Private beach" },
  { key: "aqua",     ar: "اكوا بارك",     en: "Aqua park" },
  { key: "pool",     ar: "مسابح مدفأة",   en: "Heated pools" },
  { key: "family",   ar: "عائلي",         en: "Family friendly" },
  { key: "kids",     ar: "نادي أطفال",    en: "Kids club" },
  { key: "spa",      ar: "سبا ومساج",     en: "Spa & wellness" },
  { key: "dive",     ar: "مركز غوص",      en: "Diving & snorkel" },
  { key: "adults",   ar: "للكبار فقط",    en: "Adults only" },
  { key: "transfer", ar: "انتقالات مطار", en: "Airport transfer" },
  { key: "alacarte", ar: "مطاعم آلاكارت", en: "À la carte dining" },
  { key: "wifi",     ar: "واي فاي مجاني", en: "Free Wi-Fi" },
  { key: "gym",      ar: "جيم لياقة",     en: "Gym" }
];

const CITY  = k => CITIES.find(c => c.key === k)   || CITIES[0];
const BOARD = k => BOARDS.find(b => b.key === k)   || BOARDS[1];
const FEAT  = k => FEATURES.find(f => f.key === k) || { key: k, ar: k, en: k };

/* --------------------------------------------------------------- Supabase --- */
const CFG = window.PHOENIX_CONFIG || {};
const CONFIGURED = !!(CFG.SUPABASE_URL && !CFG.SUPABASE_URL.includes("YOUR-PROJECT-ID"));

function makeClient() {
  if (!CONFIGURED || !window.supabase) return null;
  return window.supabase.createClient(CFG.SUPABASE_URL, CFG.SUPABASE_ANON_KEY);
}

/* -------------------------------------------------- WhatsApp message text --- */
const waLink = (number, msg) =>
  `https://wa.me/${number}?text=${encodeURIComponent(msg)}`;

function waHotelMessage(h, lang) {
  const price = Number(h.price || 0).toLocaleString("en-US");
  return lang === "ar"
    ? `السلام عليكم 👋\nمهتم بالحجز في:\n🏨 ${h.name_ar}\n📍 ${CITY(h.city).ar}\n⭐ ${h.stars} نجوم — ${BOARD(h.board).ar}\n💰 ${price} ج.م / الليلة\n\nممكن التفاصيل والتوافر؟`
    : `Hi 👋\nI'm interested in booking:\n🏨 ${h.name_en}\n📍 ${CITY(h.city).en}\n⭐ ${h.stars}-star — ${BOARD(h.board).en}\n💰 EGP ${price} / night\n\nCould you share details and availability?`;
}

/* ------------------------------------------- browser-side image compression --
   A 20 MB photo straight off a phone becomes ~200 KB before it is uploaded.
   This is what keeps the site fast on Egyptian mobile data and keeps the
   free storage tier from filling up.                                        */
function compressImage(file, maxW, quality) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    img.onload = () => {
      URL.revokeObjectURL(url);
      const scale = Math.min(1, maxW / img.width);
      const cv = document.createElement("canvas");
      cv.width  = Math.round(img.width  * scale);
      cv.height = Math.round(img.height * scale);
      const ctx = cv.getContext("2d");
      ctx.imageSmoothingQuality = "high";
      ctx.drawImage(img, 0, 0, cv.width, cv.height);
      cv.toBlob(
        b => (b ? resolve(b) : reject(new Error("compress failed"))),
        "image/jpeg",
        quality
      );
    };
    img.onerror = () => { URL.revokeObjectURL(url); reject(new Error("not an image")); };
    img.src = url;
  });
}
