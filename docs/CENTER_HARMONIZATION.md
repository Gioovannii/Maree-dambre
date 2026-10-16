# Centre harmonization

The town uses `CentreAmbreVivant.imageset/CentreAmbreVivant.png`, generated with the built-in ImageGen editor from the original empty town background and the living domain as a style reference. The original asset is retained.

The scene keeps every existing town lot and the central hall anchor. Buildings are still separate, movable game objects; they are not baked into the new background. Construction, relocation and save identifiers are unchanged.

The town and domain share the title treatment, native `TideLevelBadge`, panel colors and selection mark. `CoastalDomainScene(mode:)` applies the same bounded water animation using a town-specific coastline mask; existing decorative pedestrians remain on the paved corridors. Both timelines respect Reduce Motion, inactive app state and frozen screenshot mode.

## Image prompt

Production art-direction harmonization. Edit IMAGE 1, the EMPTY TOWN CENTER MAP, to match the premium hand-painted illustrated Mediterranean world of IMAGE 2 (style reference only, countryside map). Keep IMAGE 1's EXACT composition, camera, coastline, roads, EMPTY construction lot positions, central circular plaza and all lot footprints. This is a background for movable buildings overlaid by the app, so DO NOT DRAW ANY BUILDINGS, people, UI, words, numbers or icons into the town. Preserve exact center of central plaza at x50% y34.5%; empty peripheral lots must remain at their existing positions. Replace the low-poly orange cartoon rendering with the same sophisticated painterly limestone, deep olive foliage, luminous turquoise sea and soft warm sunlight as image 2. Main change: quieter pale warm grey/ivory limestone paving with gentle warm highlights, not uniform orange cobbles; clearly readable paved corridors and clean open building lots. Low plot boundary walls should look integrated, light limestone edging, not raised toy platforms. Sparse Mediterranean planting, cypresses and olive bushes at perimeter, teal and muted amber details on a few cloth pennants or pottery if natural, no saturation overload. Lighting from upper left, realistic gentle shadows and coherent scale. Sea at the upper coast and bottom harbor retains EXACT shore shapes so existing water masks can align. At bottom left remove repeated/duplicated scenery artifacts and render one believable continuous rocky bank. Preserve every functional lot and walkway; no new buildings or lots. No fog, bloom, photorealism or giant decorative props. Output same portrait aspect/framing as image 1, professional polished strategy-game background.

## Verification

The domain/layout and French/English catalog checks pass. The town was inspected on iPhone and iPad. In the isolated demo fixture, the warehouse was moved from lot 7 to lot 8 through its accessibility action; the source became empty and the destination retained the warehouse. Phase 0 and 0.75 captures confirm moving harbor water with stationary buildings and menus.
