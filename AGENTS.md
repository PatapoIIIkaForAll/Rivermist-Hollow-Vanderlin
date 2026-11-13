# Agent workflow

Follow `ai_navigation/AGENTS.md` and start repository navigation through
`ai_navigation/router.md`.

After changing DM source or `vanderlin.dme`, run:

```powershell
python tools/dm_diagnostics.py
```

This runs the installed DreamMaker language server, including the DreamChecker
enabled in `SpacemanDMM.toml`, and prints diagnostics directly to the agent.
Fix new errors introduced by your changes before finishing. Do not ask the user
to relay VS Code diagnostics that this command can retrieve. Compile using the
repository build workflow as well; language-server checks do not replace BYOND.

Use `--json` for full diagnostic objects, including related locations. Checks
read saved files from disk, not unsaved VS Code buffers. Exit codes are 0 for no
errors (warnings/hints may remain), 1 for diagnostic errors, and 2 for a failed
check. A failed check is not a clean result. See `tools/dm_diagnostics.md`.

Includes in `vanderlin.dme` and `code/modules/unit_tests/_unit_tests.dm` must
stay in the order CI checks. After adding or removing an include anywhere in
the `// BEGIN_INCLUDE` block, run:

```powershell
python tools/ticked_file_enforcement/sort_includes.py
```

Never commit or push without user authorization.
