# White Mist storefront (Phase 4: local build on mock data)

Vanilla HTML, CSS and JavaScript (ES modules). No framework, no dependencies.

## Run locally
    node scripts/dev-server.mjs        # http://localhost:4173
    node scripts/build.mjs             # writes dist/ with shared partials stamped in

The dev server mirrors the planned Vercel rewrites: `/product/:slug`, `/shop/:category`, clean URLs.

## Where things are
- `data/mock-data.js`: ALL sample data (products, variants, prices, stock, promo codes, dose chart, orders). Nothing here is confirmed by the client.
- `js/core/store.js`: the data layer (localStorage now). Phase 8 swaps each function body for Supabase / serverless calls.
- `js/core/cart-state.js`: cart in the browser (variant id + qty only; prices are always re-quoted).
- `js/components/`, `js/pages/`, `js/admin/`: UI, page scripts, admin scripts.
- `partials/`: header, footer, head, admin header, stamped into every page at serve/build time.

## Not connected yet (each needs explicit approval first)
Supabase (schema, RLS, Auth), Cloudinary, Razorpay, environment secrets, deployment.

## Phase 5 — production integration (Supabase + Cloudinary)

- **Data:** `js/core/config.js` → `dataSource: 'supabase'`. Browser holds only the project URL and the *publishable* key. All prices, stock, promo, shipping and totals are decided by Postgres functions (`quote_cart`, `create_order`, `admin_dashboard`). Migrations are in `supabase/migrations/` (0001–0006; 0005 was applied via the tool, it only restarted the order-number sequence at 1001).
- **Admin:** Supabase Auth + `admin_users` allow-list + RLS. To add an admin: create the user in Supabase → Authentication, then `insert into admin_users select id from auth.users where email='<email>'`. Turn off public sign-ups.
- **Images:** Cloudinary public IDs (`white-mist/{products,variants,categories,branding}/…`) are stored in the DB; `js/core/cloud.js` builds `f_auto,q_auto` URLs. Uploads go through the `sign-upload` Edge Function (admin JWT required); secrets `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` live only in Supabase Edge Function secrets.
- **Orders are real now.** Placeholder catalogue and the WELCOME10 / FLAT50 codes are still placeholders until the client supplies real content.
- **Razorpay boundary (not implemented):** a server holding the service-role key calls `create_order(..., 'online', ...)` → creates the Razorpay order → verifies the payment signature → calls `mark_order_paid(order_id, payment_id)`; on failure `mark_payment_failed`. Both are service_role-only and idempotent. The browser can never mark an order paid.
- `js/core/store-mock.js` and `data/mock-data.js` are dev-only; `npm run build` refuses `dataSource: 'mock'` and excludes them.

- **Verify everything:** see `VERIFY.md` (double-click `verify.command` / `verify.bat`).
