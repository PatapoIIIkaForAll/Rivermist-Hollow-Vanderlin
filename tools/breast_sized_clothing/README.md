# Breast-sized clothing sheets

`modular_rmh/icons/clothing/onmob/breast_sized/<state>.dmi` are built, never edited by hand.

```
python tools/breast_sized_clothing/pack_breast_sized.py [state ...] [--preview <dir>]
```

## Sources

| File | Holds |
|---|---|
| `tools/breast_sized_clothing/src/<state>.dmi` | the layer archive of one garment: `<p>_<N>_hide` masks, `<p>_pair_<N>_BEHIND` / `_ADJ` cloth over the breasts with `_front` / `_side` splits, `<p>_<N>_extra`, `<p>_<N>_cover_front`, each as a still, and for sizes 5-8 as per-frame stills `<p>_f<K>_...` (walk), `<p>_r<K>_...` (run), `<p>_s<K>_...` (squeeze); `<p>` is `<state>_f` or `<state>_f_detail` |
| the garment's own worn DMI (`GARMENTS` in the script) | the female worn base `<state>_f` and, where painted, `<state>_f_detail` |

The archives are the only copy of this art in the repository. The stencil files they were packed from stayed with the artist. To redraw a layer, edit the archive state in Dream Maker and rebuild.

## Output states

`<p>` is `<state>_f` or `<state>_f_detail`, N the wearer's visible breast size.

| State | Frames | Shown by |
|---|---|---|
| `<p>_<N>`, N 0-4 | 4 dirs, still: cut base plus all cloth | the worn overlay |
| `<p>_<N>`, N 5-8 | 4 dirs, still + walk movement; south is the cut base only | the worn overlay |
| `<p>_<N>_run` | still + run movement | the worn overlay while sprinting |
| `<p>_<N>_front` | south only, still + walk movement: cover + cloth over the breasts | the garment's vis_contents child |
| `<p>_<N>_run_front` | run movement | the child while sprinting |
| `<p>_<N>_<shot>_front` | one-shot, `loop = 1` | `flick()` on the child, same shot names as `tools/breast_anim` |
| `<p>_<N>_jiggle_front` | run cycle, loops | jiggle emote, the child |
| `<p>_<N>_jiggle` | 4 dirs, run cycle, loops | jiggle emote, the worn overlay |
| `<p>_<N>_still` | 4 dirs, still: the whole garment, no movement | wearers with the animation preference off |

The cut base's south frame has no cloth over the breasts because the body's breasts child draws above every overlay of the mob; the garment child, one layer above it, carries that cloth so breast and cloth move together.

### Races with their own clothing art

`CUSTOM_VARIANTS` in `pack_breast_sized.py` maps a clothing tag to a row shift (`dwarf: 3`). For each tag whose worn state `<p>_<tag>` exists (`fallgown_f_dwarf`, detail `fallgown_f_dwarf_detail`), the packer emits the whole set again as `<p>_<N>_<tag>...` (`fallgown_f_7_dwarf`, `fallgown_f_7_dwarf_front`, `fallgown_f_7_dwarf_still`, ...) with that race's worn sprite as the base and the human layers moved down by the shift: dwarf clothing art sits 4 px lower than the female art while the layers were drawn for breasts at -1. No extra drawing is needed; the game picks `<N>_<tag>` for wearers whose species has `custom_clothes`. Halflings share the dwarf tag. A race without a `<p>_<tag>` worn state keeps its plain sprite.

## Adding a garment

### What the artist draws

One DMI with `<state>_f_<N>` for every size N 0-8. Each state has 4 directions (S, N, E, W) and shows the whole female garment drawn over the body breasts of size N. Size 0 may be the plain garment.

If the worn DMI has `<state>_f_detail` (the recoloured paint layer), draw `<state>_f_detail_<N>` too, in the same DMI or a second one.

Draw over the breasts where the game puts them: `pair_<N>_ADJ` (S, E, W) and `pair_<N>_BEHIND` (N) from `modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi`, 1 px lower. Use only fully opaque pixels where the garment covers its own base.

### Commands, in order

1. Draft (optional): `python -I tools/breast_sized_clothing/draft_from_base.py <worn.dmi> <state>_f <drawing.dmi> --style cups|silk|ropes --preview <out.png>`. It writes rough `<state>_f_<N>` states to finish by hand.
2. Canvas (optional, needs Aseprite): `python -I tools/breast_sized_clothing/mannequin/make_garment_canvas.py to-aseprite <drawing.dmi> <state>_f.aseprite`, draw, then `... to-dmi <state>_f.aseprite <drawing.dmi>` (add `--detail-out <drawing.dmi>` when the canvas has a detail layer). `mannequin/make_mannequin.py <out.aseprite>` makes an empty mannequin. Without Aseprite both stop with "Aseprite not found"; set `ASEPRITE` to the executable.
3. Profile (optional): write `tools/breast_sized_clothing/profiles/<state>_f.json`. Without it every layer uses `stretch`.
4. Archive: `python -I tools/breast_sized_clothing/make_archive.py <drawing.dmi> <worn.dmi> <state> [--detail <detail.dmi>]`. It writes `src/<state>.dmi`. It stops when base minus hide plus pair plus extra does not rebuild the drawing exactly; semi-transparent pixels over the base are the usual cause. `--force` writes anyway.
5. Sheet: add `"<state>": "<worn.dmi>"` to `GARMENTS` in `pack_breast_sized.py`, then run `python -I tools/breast_sized_clothing/pack_breast_sized.py <state> --preview <dir>`. To try a garment without editing `GARMENTS`, pass `--extra <state>=<worn.dmi>` instead.
6. Add the DM lines below and build.

### Profile keys

- `pair`: how the cloth over the breasts follows the animation.
- `extra`: how the garment pixels outside the breasts that change with size follow it.
- `hide`: how the mask that cuts the base follows it.
- Each of the three takes one mode, or one per direction: `{"S": "bottom", "default": "stretch"}`.
- `stretch`: top edge stays, bottom edge follows the breast (default).
- `bottom`: each column shifts with the breast's bottom edge; for cups that hold the breast up.
- `free`: each column follows both edges of the breast; for closed garments.
- `rigid`: the whole layer shifts as one piece.
- `cover`: like `free`, but edges only move outwards.
- `none`: the layer does not move.
- `cut_under_clothing`: `true` cuts the base under the cloth's rest place, so the body shows there (open garments); `"fill"` keeps the cloth's rest pixels there (closed garments); default off.
- `pin_unchanged`: directions, for example `["N"]`, where pixels equal to the plain garment stay put over the moving breast.
- `worn`: the worn DMI path; `make_archive.py` takes the worn DMI as an argument and ignores this key.

### DM lines on the item

```
breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/<state>.dmi'
breast_sized_closed = TRUE
boobed = TRUE
```

Set `breast_sized_closed = TRUE` when the garment covers the whole chest, `FALSE` (the default) when it is open.

### When a size or state is missing

- A size with no drawing is left out of the archive and the sheet. At that size the game draws the plain worn sprite with its `_boob` overlay.
- Without size 5 the packer skips every size of that layer (`<state>_f` or `<state>_f_detail`).
- Without a detail drawing the archive and sheet have no detail layer, and the sized sprite shows no paint.
- Without `<state>_f` in the worn DMI both `make_archive.py` and the packer stop.
- A subtype whose `icon_state` has no states in the sheet keeps its plain sprite.
