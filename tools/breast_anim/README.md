# Breast animation sheet

`modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi` is built, never edited by hand.

```
python tools/breast_anim/build_breast_anims.py [--preview <dir>] [--check-ratwood <dmi>]
```

## Sources

| File | Holds | Edit it with |
|---|---|---|
| `modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi` | every still: pair 0-8, quad 0-7, sextuple 0-7, layers ADJ and BEHIND | Dream Maker |
| `tools/breast_anim/src/frames.dmi` | per-frame stills for pair 5-8: `pair_N_fK_L` walk (K 1-8), `pair_N_rK_L` run (1-8), `pair_N_sK_L` squeeze (1-6) | Dream Maker |

`import_frames.py <sheet.dmi> src/frames.dmi` pulls those stills out of any sheet that carries them (that is how the PR 272 art came in).

## Output states

Animated sizes N = 5-8. `<L>` is ADJ or BEHIND.

| State | Frames | Shown by |
|---|---|---|
| `pair_N_<L>` | the plain still | dummies, previews, animation off |
| `pair_N_side_ADJ` | still + walk movement, south blank | body overlay |
| `pair_N_run_side_ADJ` | still + run movement, south blank | body overlay while sprinting |
| `pair_N_front_ADJ` | still + walk movement, south only | the vis_contents child |
| `pair_N_run_front_ADJ` | still + run movement, south only | child while sprinting |
| `pair_N_<shot>_front_ADJ` | one-shot, `loop = 1`, south only | `flick()` on the child |
| `pair_N_jiggle_front_ADJ` / `pair_N_jiggle_side_ADJ` | run cycle, loops | jiggle emote |
| `pair_N_side_BEHIND`, `pair_N_run_side_BEHIND`, `pair_N_jiggle_side_BEHIND` | walk, run, loop | body overlay (BEHIND has no south pixels) |
| `<type>_N_jiggle_<L>` for every other still | one-pixel sway, loops | jiggle emote on sizes without drawn frames |

The marker (`side`, `front`, `run`, shot) sits before the layer suffix because the sprite accessory code appends `_ADJ` / `_BEHIND` itself.

Shots (`SHOTS` in the build script): `walk_half`, `walk`, `laugh`, `cough`, `clearthroat`, `jump`, `dance`, `shiver`, `hit`, `slap_b`, `fall`, `land`, `stop`, `bounce`, `pump2`, `pump3`, `squeeze`, `paizuri`, `heft`, `suckle_a`, `suckle_b`. Frame order and tick delays are the tables of PR 272.

Generated jiggle frames follow Ratwood's `generate_jiggle_states.py` exactly, so sizes whose stills match Ratwood's get the same pixels (`--check-ratwood` proves it).
