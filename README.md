# molt-framework-skill

A [Claude Code](https://claude.com/claude-code) plugin with one skill, `using-molt-framework`, for projects that build HTML with [`molt-framework`](https://crates.io/crates/molt-framework) (Rust).

It is what an agent should check **before reading the crate's source**: which APIs exist in the version the project has, the behaviours that surprise, and a symptom-to-fix table. It works offline.

## Install

```text
/plugin marketplace add micheltlutz/molt-framework-skill
/plugin install molt-framework@molt
```

The marketplace is called `molt`; the plugin is called `molt-framework`.

## What it does

The skill triggers when a project depends on `molt-framework`, or when Rust code builds HTML with Molt. It tells the agent to:

1. read the installed version from `Cargo.lock`;
2. look the API up in a table with one column per version, instead of searching the source for something that does not exist yet;
3. apply the rules that hold in every version (escape once, imports, the position of `.text()`, name shadowing);
4. use a recipe for what Molt 1.x lacks, and the new API on 2.x;
5. verify by asserting on the rendered string before saying it is done.

Two reference pages are bundled (`references/capabilities.md`, `references/pitfalls.md`). They are snapshots of the Molt repository's `docs/` pages, stamped with the commit they came from. From the Molt version that ships those pages in the published crate, the skill sends the agent to the crate's own copy in `~/.cargo/registry/src/*/molt-framework-<version>/`.

## Layout

```text
.claude-plugin/marketplace.json            the marketplace ("molt")
plugins/molt-framework/
  .claude-plugin/plugin.json               the plugin
  skills/using-molt-framework/
    SKILL.md
    references/capabilities.md             snapshot of Molt's docs/capabilities.md
    references/pitfalls.md                 snapshot of Molt's docs/pitfalls.md
scripts/sync-references.sh                 refreshes the two snapshots
docs/retrieval-checks.md                   questions and expected answers used to test the skill
```

## Working on it

Try it without installing:

```bash
claude --plugin-dir plugins/molt-framework
```

Validate both manifests:

```bash
claude plugin validate .
claude plugin validate plugins/molt-framework
```

Refresh the bundled pages from the Molt repository (needs `gh`, logged in):

```bash
bash scripts/sync-references.sh            # from `develop`
bash scripts/sync-references.sh <git-ref>  # from a tag or a commit
```

After syncing, re-run the checks in `docs/retrieval-checks.md`, and re-read `SKILL.md`: it names the Molt versions in prose ("published 1.x", "unreleased 2.0") and those sentences need a hand edit when a release is cut.

## Releasing

1. Update `CHANGELOG.md`.
2. Raise `version` in **both** `plugins/molt-framework/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
3. `claude plugin validate .` and `claude plugin validate plugins/molt-framework`.
4. Commit, then tag with `claude plugin tag` (see `claude plugin tag --help`) and push.

People update with `/plugin update molt-framework`.

## Installed a personal copy before?

If `~/.claude/skills/using-molt-framework/` exists, remove it after installing the plugin, or the skill is listed twice.

## License

MIT. See [LICENSE](LICENSE).
