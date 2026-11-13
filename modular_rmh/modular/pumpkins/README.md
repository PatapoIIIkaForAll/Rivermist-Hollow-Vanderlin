# Pumpkins

Pumpkins, pumpkin foods and carved pumpkin lanterns, ported from Twilight-Axis. The recipes use our
own cooking tools. Design notes: `docs/pumpkin-port-DESIGN.md`.

## Growing

- Pumpkin seeds come from the Zalad seed trader (cost 3), from wild pumpkin patches, from mixed
  seeds, and from pumpkins.
- A pumpkin patch grows in 7 minutes and gives 1 to 3 pumpkins. It is a heavy feeder (nitrogen 35,
  potassium 30) and gives back phosphorus 20. It is thirsty and stands cold well.
- Wild pumpkin patches grow on the fields, in the forest, in the bog and in the basin. Search one by
  hand for seeds and fibres. One patch in 10 also hides a whole pumpkin.

## The whole pumpkin

| Action | Result |
|---|---|
| Right-click with a small blade | Cuts the top open. |
| Spoon on an open pumpkin | Scoops 1 slice. After the 6th slice you get the shell and 1 to 4 seeds. |
| Left-click with a small blade, pumpkin on a table | Chops it into 6 slices (more with high food preparation). The shell and seeds are lost. |
| Blunt intent | Smashes it for 1 to 4 seeds. |

A whole pumpkin is too big to eat. Seeds keep the plant's genetics.

## Carving

Use a small blade on a pumpkin shell to open the carving window. Pick one of 8 designs; the carve
takes 2 seconds and needs the blade still in hand. The lantern is worn on the head and hides the face.
Put a plain or yellow candle inside to fuel it (a worn candle gives less fuel). A lit candle lights it
at once. Gold, silver, skull and Sune's candles never burn out, so they do not fit.

## Food

| Food | How |
|---|---|
| Pumpkin mash | Pumpkin slice in a pan. |
| Pumpkin pie | Pie bottom + 2 slices or mash + 1 egg, then sugar to finish (open pie). Bake in the oven. |
| Pumpkin loaf | Butterdough + slice or mash on a table. Bake in the oven. Slice into 6. |
| Pumpkin balls | Butterdough slice + slice or mash on a table. Fry in a pan or bake. |
| Roasted pumpkin seeds | Pumpkin seeds in a pan. |
| Pumpkin spice | Roasted pumpkin seeds in a millstone. |
| Pumpkin soup | Pumpkin slice in a pot, up to 3 more vegetables. |
| Roasted pumpkin soup | Pumpkin mash in a pot, up to 3 more vegetables. |
| Tea or coffee with pumpkin spice | Add pumpkin spice to any tea or coffee pot, with sugar and milk if you like. |
| Pumpkin Ale | Keg: 4 pumpkin slices + 1 pumpkin spice + 100 water. |

Cows and goats eat pumpkins and pumpkin slices.

## Art

`icons/` is built by `F:/ss13 dev/pumpkin_art_generator/build_dmis.py` (run from the repo root;
`--preview-only` writes only a preview). It copies the Twilight-Axis sprites and renames the loaf
and ball bite stages to our `[base][bitecount]` rule. The lantern sprites used to live in the
Halloween hunt DMIs; the generator moved them here.
