---
name: using-molt-framework
description: Use when a project depends on molt-framework (listed in Cargo.toml or Cargo.lock) or when writing Rust that builds HTML with Molt (Element, Document, SeoBuilder, StaticSiteGenerator, SitemapGenerator, html! macro, WASM bindings). Also when Molt output has wrong characters or children out of order, or an API seems to be missing.
---

# Using molt-framework

Molt builds a tree of values and renders it once to a `String`. This skill is what to check **before reading the crate source**.

## First: which version?

`grep -A1 'name = "molt-framework"' Cargo.lock`. 1.x and 2.x (2.0.0 is on crates.io) differ (text order, `<html>` attributes, SEO setters, directory copy, hashed assets). `references/capabilities.md` section 3 has a column per version. If your version lacks an API, use the recipe below; do not search the source for it. On 2.x, prefer the new APIs listed in that table over the recipes.

## Upgrading a project to 2.x

Read `MIGRATION.md` (section "2.0.0") in the crate. The two things that bite:

- **`.text()` order.** Output changes wherever `.text()` follows `.child(..)`; re-run the tests.
- **`clean(true)` on a `dist` made by 1.x** fails with `SsgError::UnsafeCleanTarget` and removes nothing. Delete `dist` once, or `touch dist/.molt-output` (`ssg::OUTPUT_MARKER`). The marker is one line of text and is uploaded with the site.

## Rules that hold in every version

- **Escape once.** Pass raw values to `text()`/`attr()`. Never put external data in `raw_text`, `Node::raw`, `Attribute::raw`, `trusted_url`.
- **Imports.** `use molt::prelude::*;` plus `molt::Document` and `molt::Layout` from the crate root. `.render()` needs `Render` (in the prelude).
- **Text after children.** On 1.x, `.text()` always renders *before* children. Write `.child(Node::text(x))` (same output on 2.x).
- `main_tag()`, `html_tag()`, `link_to(href)`, `image(src, alt)`, `stylesheet(href)`, `script_src(src)`.
- **Constructors are named like tags** (`title`, `link`, `label`, `span`...). A local or parameter with the same name shadows them (`E0618`): call it `page_title`. `title()` builds `<title>`; `Document::new(lang)` takes the *language*, and the title goes in `head_children([title().text(..)])`.
- Attributes render in insertion order. `data_attr("a-b", v)` writes `data-a-b`.
- `Element::render()` is one line; `Document::render()` is pretty with doctype; `render_compact()` is one line.

## 1.x gaps: recipes

| Need | Recipe |
| --- | --- |
| Attributes on `<html>` | `html_tag().attr("lang", l).attr("data-theme", "dark").child(head()...).child(body()...)`, then `format!("<!DOCTYPE html>\n{}", root.render())` |
| canonical, hreflang, og:locale, og:image:*, theme-color, robots | `link().attr("rel", "canonical").attr("href", u)`; `seo::meta_name(n, c)`; `seo::meta_property(p, c)`; `seo::common(..)` for title, description, robots |
| Preload font | `link().attr("rel","preload").attr("as","font").attr("type","font/woff2").attr("href",h).bool_attr("crossorigin")` |
| Write a site | `let site = StaticSiteGenerator::new(out); site.clean(true)?;` then `site.generate(&doc, "index.html", &opts)?`, `site.write_file(&s, path)?`. `SsgError` converts to `io::Error` with `?`. Render and validate everything **before** `clean`, so a failed build keeps the old output |
| Copy a directory, hashed names | walk the tree and `site.copy_asset(from, rel)` per file; hash it yourself (FNV-1a) and rewrite the URLs |
| Sitemap | `SitemapGenerator::generate(&[SitemapUrl::new(loc).lastmod(d).changefreq(ChangeFreq::Monthly).priority(1.0)])`; no `alternate` (put hreflang in `<head>`) |
| Assert on HTML | no tree query: assert on rendered substrings; `accessibility::audit(&Node)` for a11y |

## Signatures (1.x)

- `Document::new(Option<&str>)`, `.head_children(iter)`, `.body_children(iter)`; render with `.render()`, `.render_compact()` or `.render_with(&RenderOptions)`. `RenderOptions::pretty()` and `::compact()`.
- `StaticSiteGenerator::new(dir)`, `.clean(create_dir: bool)`, `.generate(&Document, "a/b.html", &RenderOptions)`, `.write_file(&str, "rel/path")`, `.copy_asset(from, "dest/rel")`. All return `Result<_, SsgError>`.
- `seo::common(title, description, keywords: Option<&[&str]>, author: Option<&str>, viewport, robots) -> Vec<Element>`; default viewport is `seo::DEFAULT_VIEWPORT`.
- `stylesheet(href)` renders `<link href=".." rel="stylesheet">` (`href` first).

## Verify before saying done

Render and assert the exact string, run `accessibility::audit` on the tree, compile the snippet.

## Read next

- `references/capabilities.md`: module map, what exists per version, behaviours that surprise.
- `references/pitfalls.md`: symptom to fix.
- Version-matched crate: `~/.cargo/registry/src/*/molt-framework-<ver>/`. From 2.x it ships `llms.txt`, `docs/agents.md`, `docs/capabilities.md` and `docs/pitfalls.md`: read those copies first; the files in `references/` are the same pages for 1.x projects. Always there: `README.md`, `GETTING_STARTED.md`, `docs/tag-catalog.md`, `examples/`.
- Working inside the Molt repository itself? Use its own `.claude/skills/molt`.
