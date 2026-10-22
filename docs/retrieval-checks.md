# Retrieval checks

Questions that the skill and its references must answer, each with the expected answer. Run them on a fresh agent that may read **only** the skill's files ("answer only from the skill; say `NOT IN THE SKILL` if it is not there"). A check passes when the answer is right **and** names the file and section it came from.

They are written as plain text on purpose. `claude plugin eval` runs cases from `evals/` against a plugin; turn these into cases once you have its case format in hand (this repository does not guess the schema).

## Questions

| # | Question | Expected answer | Where it lives |
| --- | --- | --- | --- |
| Q1 | On Molt 1.1.1, how do I copy a directory into the output and write CSS with a content hash in its name? What changes on 2.x? | 1.1.1 has neither: walk the tree and call `copy_asset` per file, hash it yourself (FNV-1a) and rewrite the URLs. On 2.x use `copy_dir` / `copy_dir_where` and `copy_asset_hashed(from, dir) -> Result<String>`, which renames one file and does not rewrite `import` or `url(...)`. | `SKILL.md` recipes; `capabilities.md` section 3 and 5 |
| Q2 | Why does `p().child(strong().text("A: ")).text("B")` print `B` first on 1.1.1, and what works on both 1.x and 2.x? | On 1.x text is a separate slot that renders before the children. Use `.child(Node::text("B"))`. From 2.0 `.text()` renders in call order. | `SKILL.md` rules; `capabilities.md` section 4 |
| Q3 | Is there a `text_content()` to read a tree's text in a test? | No, on purpose: text is stored escaped and `<script>`/`<style>` content is raw in the same field. Use `find(..).render()` (2.x) or assert on rendered substrings. | `capabilities.md` section 5 |
| Q4 | After moving to 2.x, `clean(true)` fails with `SsgError::UnsafeCleanTarget` on an old `dist`. Why, and how do I get unstuck? Does the fix leave an extra file? | 2.x only empties a directory that is missing, empty or holds `.molt-output`; a 1.x `dist` has none, and nothing is removed. Delete `dist` once, or `touch dist/.molt-output`. The marker is one line of text and is uploaded with the site. | `SKILL.md` "Upgrading a project to 2.x" |
| Q5 | My function takes a parameter called `title` and calls `title().text(..)`: `E0618`. Why? | The prelude brings constructors named like tags; the parameter shadows `title()`. Rename it (`page_title`). `Document::new` takes the language; the title goes in `head_children([title().text(..)])`. | `SKILL.md` rules |
| Q6 | Which published version of molt-framework is the newest according to the skill, and which agent-facing files does that version ship inside the crate? | 2.0.0 (on crates.io). The crate ships `llms.txt`, `docs/agents.md`, `docs/capabilities.md` and `docs/pitfalls.md`. | `SKILL.md` "First: which version?" and "Read next" |

## Application tasks

Both run on a throwaway crate pinned to `molt-framework = "=1.1.1"`, with `cargo ... --offline`. The agent keeps an `attempts.md` with one line per thing that did not compile or behaved unexpectedly. Run each with and without the skill and compare tool calls, tokens and the library files read.

- **A. Head and contact line.** `head_tags()` for a bilingual page (title, description, canonical, hreflang for en-US, pt-BR and x-default, `og:locale` and its alternate, `og:image` with width, height and alt, `theme-color`, robots `index, follow, max-image-preview:large`); `page()` with `<html lang="en" data-theme="dark">` and `<p><strong>Controller: </strong>Ada Lovelace</p>` where the name is plain text after the `<strong>`; tests on the exact HTML.
- **B. Static site.** `build(out)` writing `index.html` and `pt-br/index.html`, the whole `assets/` tree copied with the CSS written as `css/site.<hash>.css` and both pages linking that URL; building twice must not leave stale files; tests on a unique temp directory.

## Results so far (2026-10-22, Sonnet, one sample each)

| Task B | Tool calls | Tokens | Time |
| --- | --- | --- | --- |
| Without the skill | 13 | 70.3k | 88 s |
| With the skill, first version | 9 | 66.9k | 77 s |
| With the skill, with signatures added | 9 | 62.0k | 70 s |

Task A: 9 calls without the skill, 7 with it (time inconclusive: 61 s against 99 s). Both versions were correct on the first try; the skill saves discovery cost, not correctness. Q1 to Q3 passed on the first run, Q4 failed until the "Upgrading to 2.x" section was added, then passed.

Q1 to Q6 on 0.2.0 (2026-10-22, Sonnet, one sample, skill files only): all six correct, each with the right file and section.
