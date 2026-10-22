# Molt Framework

A Claude Code plugin with one skill, `using-molt-framework`, for projects that build HTML with [`molt-framework`](https://crates.io/crates/molt-framework), a Rust crate.

It is what an agent should check **before reading the crate's source**: which APIs exist in the version the project has, the behaviours that surprise, and a symptom-to-fix table.

## What the skill does

It triggers when a project depends on `molt-framework`, or when Rust code builds HTML with Molt. It tells the agent to:

1. read the installed version from `Cargo.lock`;
2. look the API up in a table with one column per version, instead of searching the source for something that does not exist yet;
3. apply the rules that hold in every version (escape once, imports, the position of `.text()`, name shadowing);
4. use a recipe for what Molt 1.x lacks, and the new API on 2.x;
5. verify by asserting on the rendered string before saying it is done.

## Install

```text
/plugin marketplace add micheltlutz/molt-framework-skill
/plugin install molt-framework@molt
```

## What it runs, sends and fetches

Nothing. The plugin is plain Markdown: `skills/using-molt-framework/SKILL.md` and two reference pages. It has no hooks, no MCP servers, no scripts, no commands and no network access, and it collects no data. See [PRIVACY.md](PRIVACY.md).

The two reference pages (`references/capabilities.md`, `references/pitfalls.md`) are snapshots of the Molt repository's `docs/` pages, each stamped with the commit it came from.

## Links

- Source and issues: <https://github.com/micheltlutz/molt-framework-skill>
- Molt framework: <https://www.molt-framework.io>

## License

MIT. See [LICENSE](LICENSE).
