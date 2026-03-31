# Coding Standards

Generated on 2026-03-14. Derived from the project's official STANDARDS.md, STYLE.md, CI.md, and HARDDELETES.md documents.
This file is the AI navigation layer's normative reference for code quality. When writing or reviewing code, treat these as hard requirements unless a maintainer explicitly overrides them.

The navigation layer may lag behind the live documents. If this file and the source docs disagree, trust the source docs.

---

## Quick Decision Table

| Situation | Rule |
|---|---|
| New atom needs setup logic | Use `Initialize()`, not `New()` |
| Need to move a mob or object | Use `SSmove_manager`, never raw `walk()` |
| Need to store a reference you don't "own" | Use `WEAKREF()` |
| Registering a signal handler | Add `SIGNAL_HANDLER` macro at top of proc |
| Referencing a proc in `RegisterSignal` | Use `PROC_REF`, `TYPE_PROC_REF`, or `GLOBAL_PROC_REF` |
| Time value in a proc argument | Include unit in name: `seconds_per_tick`, not `delta_time` |
| Using `process()` for timed effects | Multiply by `seconds_per_tick` — never frame-dependent |
| Overlay visuals | Cache as `static` appearances via `iconstate2appearance` / `icon2appearance` |
| Player input validation | Always sanitize; check state before AND after async input |
| SQL queries with input data | Always use parameterized queries and `format_table_name` |

---

## Structure and Object Orientation

### Use `Initialize()` over `New()` for atoms

The map loader calls `New()` for every atom during world load — this creates a performance cliff. `Initialize()` is the correct override for setup logic on atoms. It integrates with the game controller's lag-aware loading system.

Do **not** casually convert existing `New()` → `Initialize()` in unrelated PRs — these chains are brittle and bugs may hide for months.

```dm
// Correct
/obj/item/my_thing/Initialize(mapload)
    . = ..()
    GLOB.my_things += src

/obj/item/my_thing/Destroy()
    GLOB.my_things -= src
    return ..()
```

### DRY — No duplicated code

Copying code between subtypes is not allowed. Use proc overrides, components, or helper procs. /tg/station is a long-term project; copypaste rot compounds quickly.

### Object-oriented structure required

Use type overrides and proc inheritance rather than adding special-case checks to existing procs. If you can't see a clean OO path, ask a maintainer — "I couldn't think of one" is not a valid exception.

### No hacky type-safety bypasses

The `:` operator (lax dereference) bypasses type checking. It is not allowed. Cast to the correct type explicitly.

```dm
// Bad
var/mob/M
M:health = 0

// Good
var/mob/living/carbon/C = M
C.health = 0
```

### No string-based type paths

Type paths must be compile-time literals, not strings. Strings produce no compile error when the type is renamed or removed.

```dm
// Bad
var/path_type = "/obj/item/baseball_bat"

// Good
var/path_type = /obj/item/baseball_bat
```

### Modular file placement

New additions should go in their own file unless the content naturally belongs with similar items (e.g. a new tool type goes in `tools.dm`). Modular placement makes PRs easier to review and revert.

### File naming

- All lowercase, no spaces, no characters that require URI escaping.
- Avoid identical filenames across different folders — runtime errors do not give the full path, making same-name files very hard to debug.

---

## Style

### Formatting

- **Tabs, not spaces** for indentation.
- No alignment tabs in the middle of lines — if the aligned-to line changes, all surrounding lines need updating.
- All type paths must begin with `/`.
- All type paths must be snake_case: `/datum/blue_bird`, not `/datum/BlueBird`.
- `datum` type paths must include `datum`: `/datum/my_thing`, not just `/my_thing`.
- Use absolute paths everywhere — nested block style makes text-search nearly impossible.

### Control flow

- No code on the same line as a control statement: `if (x) return` → not allowed.
- Comparisons: `thing operator number`, not `number operator thing`.
- **Use early returns.** Avoid deep nesting — guard-clause at the top and return, don't wrap the whole proc in `if`.

```dm
// Bad — deep nesting
/proc/do_thing()
    if (condition_a)
        if (condition_b)
            do_stuff()

// Good — early returns
/proc/do_thing()
    if (!condition_a)
        return
    if (!condition_b)
        return
    do_stuff()
```

### No magic numbers or strings

All non-obvious literals must be `#define`d with a descriptive name. Mode flags, state IDs, damage constants — all of them.

```dm
// Bad
if (mode == 2)

// Good
#define MY_MODE_FAST 2
if (mode == MY_MODE_FAST)
```

### No unnecessary getter or setter procs

Do not make procs that are used in one or two places, and that return single static variables or something that could be calculated "on the spot". It clutters the codebase.

```dm
// Bad
#define SOME_DATA "data"
proc/return_some_data()
    return SOME_DATA

proc/actual_opreration()
    var/data_operation = return_some_data()

// Good
#define SOME_DATA "data"

proc/actual_opreration()
    var/data_operation = SOME_DATA
```
### Time values — use defines, not raw deciseconds

Use the project's `SECONDS`, `MINUTES`, `HOURS` defines. Raw decisecond literals are error-prone and unreadable.

```dm
// Bad
do_after(mob, 15)

// Good
do_after(mob, 1.5 SECONDS)
```

### Variables

- Declare with `var/name` format.
- Descriptive names — `victim` not `M`, `weapon` not `A`.
- Avoid abbreviations unless universally obvious (`i` in numeric loops is fine).
- Avoid negative variable names: `is_flying` not `is_not_flying`.
- Time-holding vars must include the unit: `delta_time_seconds`, `seconds_per_tick`.
- Use `static` keyword instead of `global` for per-type shared vars — `static` actually describes the behavior.

### Dot variable (`.`)

`. = ..()` is the accepted and preferred pattern for capturing parent return values. Other uses of `.` as an implicit return accumulator are discouraged — they produce code that is hard to read and impossible to LSP-trace.

Exception: `.` is acceptable when the proc needs runtime-resilience (the proc should return a safe default even if it errors mid-way). Always pair with an explicit `return .` at the end.

```dm
// Accepted — capturing parent return
/obj/item/spoon/attack()
    . = ..()
    visible_message("Whack!")

// Acceptable — runtime-resilient early exit
/proc/fragile_proc()
    . = "safe_default"
    if (!do_something())
        return .
    do_more()
    return .
```

### Operators

- Boolean/logic/comparison operators: space on both sides (`a && b`, `x == y`).
- Bitwise AND `&`: `variable & CONSTANT`, never `CONSTANT & variable`.
- Access operators `.` and `:`: no spaces.
- `!` (logical not): no space after.
- Associated list string keys must be quoted: `list("a" = "b")`, not `list(a = "b")`.

### Loops

- Prefer `for(var/i in 1 to N)` over C-style `for(var/i = 1, i <= N, i++)` — the DM-native form is faster.
- Exception: if the bound or iterator changes inside the loop body, you **must** use the C-style form.
- Prefer `for(var/A in list)` over `for(var/i in 1 to list.len)` — profiled as faster.
- `for(var/Type/thing as anything in list)` — use `as anything` to skip implicit istype filtering when the list is known-clean. This also surfaces null entries (which signal harddel bugs) as runtimes rather than silently skipping them.

---

## Signals and Components

### `PROC_REF` family — mandatory in `RegisterSignal`

Always use the correct macro. Using a raw proc name is fragile — renames break silently.

| Relationship | Macro |
|---|---|
| Proc on same type or ancestor | `PROC_REF(proc_name)` |
| Proc on an unrelated type | `TYPE_PROC_REF(/the/type, proc_name)` |
| Global proc | `GLOBAL_PROC_REF(proc_name)` |
| Verb (same/ancestor) | `VERB_REF(verb_name)` |
| Verb (unrelated type) | `TYPE_VERB_REF(/the/type, verb_name)` |

### `SIGNAL_HANDLER` — mandatory in all signal callbacks

Every proc registered with `RegisterSignal` must begin with `SIGNAL_HANDLER`. This makes the intent explicit and enables a lint that prevents sleeping inside the handler.

Any sleeping behavior inside a signal handler must be wrapped in `INVOKE_ASYNC()`.

```dm
/type/proc/on_something(datum/source)
    SIGNAL_HANDLER
    do_work()  // synchronous
    INVOKE_ASYNC(src, PROC_REF(do_slow_work))  // async if sleep needed
```

### `SHOULD_CALL_PARENT(TRUE)` — required when adding signals to root procs

When a root-level proc sends a signal, add `SHOULD_CALL_PARENT(TRUE)` to ensure subtypes don't skip the signal.

### `override = TRUE` — document why

Registering the same signal twice on the same object is normally a bug and throws a runtime. If it is genuinely intentional, silence it with `override = TRUE` and add a comment explaining the reasoning.

---

## Garbage Collection and Hard Deletes

For the full theory, see the project's `HARDDELETES.md`. This section is the navigation-layer summary.

### What causes a hard delete

An object hard-deletes when the GC cannot find and clear all references to it automatically. Hard-deletes are expensive (memory scan). Common causes:

- Stored in a var or list that is never cleared
- Has a tag
- Is in `contents` or `vis_contents`
- Held by a sleeping proc (including `usr`, `src`, and all locals)
- Static or global var pointing to it
- `walk()` internal queue (call `walk(obj, 0)` / `SSmove_manager.stop_looping()` to clear)

### The `Destroy()` contract

`Destroy()` has one job: clear all references to `src`. Nothing else. No side effects.

```dm
/obj/item/my_thing/Destroy()
    GLOB.my_things -= src   // clear global list ref
    return ..()             // always call parent last
```

### Reference ownership patterns

**Owning reference (paired):** Both objects hold a reference to each other. Clear both sides in `Destroy()`.

**Non-owning reference:** Use `WEAKREF()`. `weakref.resolve()` returns null if the target is deleted — always null-check the result and clear the weakref if null.

```dm
/somemob/proc/get_target_value()
    if (!weak_target)
        return 0
    var/mob/target = weak_target.resolve()
    if (!target)
        weak_target = null
        return 0
    return target.health
```

**Last-resort (signal-based cleanup):** If a reference is too hot to weakref and the target doesn't "own" you, register on `COMSIG_QDELETING`.

```dm
/somemob/proc/set_target(mob/new_target)
    if (target)
        UnregisterSignal(target, COMSIG_QDELETING)
    target = new_target
    if (target)
        RegisterSignal(target, COMSIG_QDELETING, PROC_REF(clear_target))

/somemob/proc/clear_target(datum/source)
    SIGNAL_HANDLER
    set_target(null)
```

### Detecting hard deletes

Enable `REFERENCE_TRACKING_STANDARD` in `_compile_options.dm`. Output goes to `[log_dir]/harddels.log` inside the round's log folder. The output identifies which object or list path holds the reference.

### BYOND walk procs — do not use

Raw BYOND `walk()` family of procs interferes with the master controller. Use `SSmove_manager` instead:

| Avoid | Use instead |
|---|---|
| `walk(obj, 0)` | `SSmove_manager.stop_looping()` |
| `walk(obj, dir)` | `SSmove_manager.move()` |
| `walk_to(obj, target)` | `SSmove_manager.move_to()` |
| `walk_towards(obj, target)` | `SSmove_manager.home_onto()` or `.move_towards_legacy()` |
| `walk_away(obj, target)` | `SSmove_manager.move_away()` |
| `walk_rand(obj)` | `SSmove_manager.move_rand()` (random walk) or `.move_to_rand()` (walk to random location) |

---

## Delta-Time and Frame Independence

`process()` procs must be frame-independent. Multiply by `seconds_per_tick`, never use a fixed per-process value.

```dm
// Bad — breaks if subsystem fire rate changes
/mob/testmob/process(seconds_per_tick)
    health -= 4   // assumes 2-second fire interval

// Good — rate-per-second, scaled by actual interval
/mob/testmob/process(seconds_per_tick)
    health -= health_loss_per_second * seconds_per_tick
```

---

## Optimization

### List initialization — avoid inline list defs on types

Defining `var/list/foo = list()` directly on a type calls a hidden `init()` proc for every instance, even if the list is never used. Initialize lists in `Initialize()` instead, and only when actually needed.

### Cache appearances — never recreate per-call

Convert icons to appearances once via `iconstate2appearance()` or `icon2appearance()` and store them as `static` vars. Reconstructing on every overlay update forces the engine to re-register the appearance and re-notify all nearby clients.

```dm
// Bad — recreates appearance every call
/obj/machine/update_overlays(blah)
    add_overlay(icon(broken_icon))

// Good — static cache, one-time conversion
/obj/machine/update_overlays(blah)
    var/static/broken_overlay
    if (isnull(broken_overlay))
        broken_overlay = icon2appearance(broken_icon)
    add_overlay(broken_overlay)
```

See `ai_navigation/visuals_guide.md` §Overlays and `ai_navigation/performance_gotchas.md` §7 for deeper context.

### Associated lists — avoid where flat lists suffice

Associated lists cost 24 bytes/item vs. 8 bytes/item for flat lists. Use indexed flat lists with named `#define`s instead of string-keyed associations when the key set is fixed.

### Prefer `for(A in list)` over index loops

The DM-native iteration form is faster than manual index incrementing (profiled).

### In-to loops — prefer DM syntax when bounds are stable

`for(var/i in 1 to N)` is faster than `for(var/i = 1, i <= N, i++)` when neither bound nor iterator changes in the loop body.

---

## Security

### Player input sanitization

Always use `stripped_input`. Treat all player input as malicious by default.

**Input stalling:** Check that the player is still in the required state **after** an `input()` resolves, not just before. Players can trigger inputs after leaving the valid state.

**Stacked inputs:** Consider whether a player opening multiple simultaneous inputs could stack effects (e.g. 10 explosions from 1 item). Apply timeouts or state locks as appropriate.

### `locate()` — always narrow scope

Bare `locate(ref)` without a list is a serious exploit vector — it can be abused to locate any object in the world. Always specify a list:

```dm
// Bad — searches entire world
var/obj/item/found = locate(ref)

// Good — scoped to contents
var/obj/item/found = locate(ref) in src.contents
```

### Topic href calls

Topic calls can be faked by clients. Validate the entire call — don't rely on the UI to only send valid states. Never expose more scope than needed.

### SQL — parameterized queries only

Never directly interpolate input into SQL strings. Use `SSdbcore.NewQuery` with a parameter list and `format_table_name` for table names.

```dm
// Bad
SSdbcore.NewQuery({"UPDATE round SET map_name = '[map.map_name]'"})

// Good
SSdbcore.NewQuery({"UPDATE [format_table_name("round")] SET map_name = :map_name WHERE id = :id"},
    list("map_name" = map.map_name, "id" = GLOB.round_id))
```

---

## Macros

### `#undef` anything you define locally

Macros leak across files based on compile order. Always `#undef` after use unless the macro belongs in `__DEFINES/`.

### Macro hygiene

- Use `do { ... } while (FALSE)` to create a local scope.
- Prefix internal variables with `__` to avoid collisions with call-site variables.
- Store arguments in local vars inside the macro if they are used more than once — otherwise proc-call arguments get invoked multiple times.
- Use `##arg` to make parameter substitution visually explicit in complex macros.
- If a macro would be cleaner as a proc, write a proc.

### Work-performing macros must look like calls

A macro that executes code at call time should use the `(...)` call syntax so the call site looks active, not constant.

```dm
// Bad — looks like a constant, actually calls pick()
#define PARTY_COLOR (pick(COLOR_BLUE, COLOR_RED))

// Good — looks like a proc call
#define PARTY_COLOR(...) (pick(COLOR_BLUE, COLOR_RED))
```

---

## Continuous Integration

CI runs on every PR. Failures block merge. The pipeline stages are:

| Stage | What it checks |
|---|---|
| **Run Linters** | Files included in `.dme`, spelling, map formatting. If "Run Linters" fails but "Annotate Lints" passes, check "Annotate Lints" for the actual error — it appears in "Files Changed" tab too. |
| **Compile Maps** | All maps (including ruins) compile cleanly. Passes here + fails below = code compiles but doesn't work. |
| **Integration Tests** | Round starts, tests run on every station map. Any runtime = failure. Map-specific failures → map-specific bug or a flaky test (ask maintainer to re-run). |
| **Screenshot Tests** | Appearance regressions. Auto-posts before/after diff on PR if something changes visually. |
| **Codeowner Reviews** | Alerts contributors who created a file that their file was changed. Not a test — if it fails, contact a maintainer. |

If a CI check is failing and the cause is unclear after reading the output, ask on the PR or in the coding Discord channel.

---

*Cross-references:*
- *Visual systems specifics: `ai_navigation/visuals_guide.md`*
- *Engine-level GC and object lifecycle: `ai_navigation/engine_limits.md`*
- *Per-pattern performance hazards: `ai_navigation/performance_gotchas.md`*
- *Signal routing: `ai_navigation/signal_map.md`*
- *Task risk gating: `ai_navigation/human_checking.md`*
