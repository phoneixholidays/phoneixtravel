# Phoenix Holidays — website + dashboard

Static site (no build step) + Supabase for data, photos and login.
Deploys unchanged to Cloudflare Pages, Netlify or Vercel.

## Files

| File | What it is |
|---|---|
| `index.html` | Public site. Reads hotels + contact details from Supabase. |
| `admin/index.html` | Owner dashboard at `/admin`. Email + password login. |
| `config.js` | **The only file you edit by hand.** Supabase URL + anon key. |
| `shared.js` | Destinations, board types, facilities, image compression. |
| `supabase-setup.sql` | Run once in the Supabase SQL editor. |
| `sample/` | Placeholder artwork shown before real hotels are added. |
| `og.jpg` | Link-preview card for WhatsApp / Facebook. |
| `_headers` | Security + caching headers (Cloudflare Pages). |

## Setup (once)

1. Create a free project at supabase.com
2. SQL Editor → paste all of `supabase-setup.sql` → Run
3. Authentication → Users → Add user (this is your `/admin` login)
4. Authentication → Providers → Email → **turn OFF "Enable email signups"**
5. Project Settings → API → copy **Project URL** and the **anon / public** key into `config.js`
6. Upload this whole folder to Cloudflare Pages

Full Arabic walkthrough: `PhoenixHolidays-Guide.pdf`

## Notes

- The **anon key is public by design** — Row Level Security protects the data. Never put the `service_role` key in any of these files.
- Photos are compressed in the browser (~1600px, 82% JPEG) before upload.
- Removing a photo in the editor deletes it from storage **when you press Save**, so cancelling is safe.
- A free Supabase project pauses after 7 days with zero traffic; restore it with one click.
- Google Drive was tested as an image host and rejected — Google blocks those URLs from a real domain.
