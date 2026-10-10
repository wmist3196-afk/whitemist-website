# White Mist — verify it works (5 minutes)

Needs Node 18+ and internet. Nothing is installed; no secrets are in this folder.

## 1. Automatic checks
Double-click **verify.command** (Mac) or **verify.bat** (Windows), or run `node scripts/verify.mjs`.
It checks the live Supabase catalogue, server-side pricing and promo rules, that anonymous users are blocked from orders/admin/payment functions, that sign-ups are off, that the upload signer rejects anonymous callers, that every mapped Cloudinary image loads, and that no secrets are in the source. Expect every line to say PASS.

## 2. Start the site
Double-click **start.command** / **start.bat** (or `node scripts/dev-server.mjs`) and open http://localhost:4173 . Do not open the HTML files directly.

## 3. Storefront (about 2 minutes)
- Home, Shop, search ("rose"), category filter: real bottles and pouches appear (4:5 crops).
- Liquid Detergent: switching fragrance changes the bottle (Ocean = blue, Floral = pink, Citrus = yellow).
- Add to cart, try code `WELCOME10` (a placeholder code) and a wrong code; delivery fee follows the ₹499 setting.
- Checkout with Cash on delivery. The online option is disabled on purpose until Razorpay is added.
- Footer and Contact: phone `tel:` link and email `mailto:` link. There is no WhatsApp link because the reference site shows none.

## 4. Admin (needs your admin password)
- http://localhost:4173/admin/login → sign in as wmist3196@gmail.com. Wrong passwords show a clear message. Logout returns to login; visiting /admin while logged out redirects to login.
- Dashboard, Products (images show in the editor), Inventory, Orders, Promos.
- Product editor → Upload image (needs the Cloudinary secrets set in Supabase) → Save. The file should appear in Cloudinary under white-mist/products or white-mist/variants and on the storefront.
- Orders: set status, cancel an order — stock is restored once.

## 5. New: countdown, combos, loader
- **First, run `supabase/migrations/0009_admin_save_combo.sql` once in the Supabase SQL editor.** Until then, saving a combo in the admin fails (everything else is already live).
- Admin → Products → open a product → *Countdown promotion*: tick it, pick an end date/time, Save. The timer appears on that product's card and product page only while it is running. Untick it and the timer disappears everywhere. After the end time it shows "Offer ended" and the sale price stops applying at checkout (enforced by the database).
- Admin → Combos → New combo: name, price, components and quantities, optional image (Cloudinary). Tick *Published* and Save; it appears in the homepage combo section. Unpublish it and it disappears. A combo has no stock of its own; it uses its components' stock, and cancelling an order restores that stock.
- Loader: shown once per browser session on first load of Home / Shop / Product; if loading fails you get "Try again / Continue anyway".
- Automated: `bash tests/run-db-tests.sh` (needs local PostgreSQL), `python3 tests/e2e/ext_t.py` and `python3 tests/e2e/admin_ext_t.py` (need `npm start` running and Playwright).

## 6. Performance notes
- Public data (settings, categories, catalogue, combos) is cached 60 s in the browser, so page-to-page browsing makes 0 repeat requests (home: 6 → 4 on first load; shop/product/home-again: 0). Prices, stock and promo codes are always re-checked by the server at cart and checkout; the cache is cleared after an order or any admin save.
- `vercel.json` adds clean URLs, the /product/:slug and /shop/:category rewrites, and short CDN cache headers for css/js (5 min, revalidated) and assets (1 day).
- Admin order list returns the newest 150 (migration 0010, already live); search and status filter still reach older orders.
- `bash tests/load/run.sh` (local PostgreSQL + pgbench) and `python3 tests/e2e/reqcount.py` repeat the measurements.

## Known open items
- Hero bubbles were rebuilt from the reference's look; exact parity could not be checked from the build sandbox. Compare side by side with white-mist.vercel.app.
- Order WM-1001 is a cancelled test order (delete it if you like).
- `white-mist/products/pouch-yellow` is a duplicate of `pouch-blue` (the reference site's two files are identical); it is unused.
- Fabric Conditioner and Stain Booster have no source image yet. WhatsApp, address and support hours are not on the reference site, so they are marked placeholders.
- Razorpay is not connected.
