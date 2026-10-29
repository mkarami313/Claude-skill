# 11 · CMS: pages, blog, banners, menus

## Model
- `Page`: static content (about, terms, contact, FAQ) — slug, title, body (rich/blocks),
  SEO fields, status (Draft | Published), version history.
- `BlogPost`: title, slug, body, cover, categories/tags, author, publish date, SEO, status.
- `Banner`/`Slider`: placement, image, link, schedule (start/end), sort order.
- `Menu`: named menus (header/footer) with nested items linking to pages/categories/URLs.
- `Widget`/block config for homepage sections (featured products, promos).

## Rules
- All content tenant-scoped; editing permissioned.
- Draft/publish workflow; content versioned so edits are reversible.
- Rich text sanitized on output; links validated.
- Served via API for the headless frontend; cache published content (20).

## API surface
- CRUD pages/posts/banners/menus; publish/unpublish; list by placement; get by slug.
