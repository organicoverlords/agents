# Yard reconstruction project contract

Repository: `organicoverlords/yard-reconstruction`

## Objective
Reconstruct the real current backyard and house geometry from the supplied original photographs first. Planting, greenery, and design work comes only after the existing geometry is grounded well enough to support it.

## Source truth
- `05.jpg` and `06.jpg` are the primary current-state references.
- `04.jpg` is historical: use it only for persistent/static geometry anchors. The railing visible there has been removed and must not be reconstructed as current geometry.
- Older images may contribute only persistent geometry such as the house, openings, terrace edges, fence posts, and stable trunks. Seasonal vegetation, furniture, grass texture, and removed structures are not current-state truth.
- Preserve the real downhill yard slope toward the rear fence / raised-bed end; do not flatten or regrade it merely because a reconstruction method prefers a simpler surface.

## Geometry acceptance
- Do not call a multiview/fused model valid unless camera viewpoints have a mutually consistent pose solution and overlapping static anchors agree in 3D.
- Monocular depth may support a reconstruction, but it is not independent multiview geometry. Label it explicitly and never promote a depth sheet to a validated yard model merely because point count or fit metrics look good.
- A historical image can anchor static parallax, but it must not become the dense/current appearance source.

## Visual acceptance
The shared `RULES.md` pixel gate is mandatory here. Before any reconstruction preview, point-cloud/mesh render, overlay, or other visually judged result is shown to the user or described as usable/correct, the producing agent must inspect the actual pixels of that exact candidate. Point counts, reprojection error, loss/fit values, tests, hashes, file existence, or successful process completion are supporting evidence only and never replace that inspection. If the preview visibly contradicts the source scene or is obviously warped, collapsed, floating, duplicated, or otherwise unusable, mark it `REJECTED`/`NOT_PROVEN` and iterate before handoff. The user is never the first visual reviewer.

## Generated imagery
Generative imagery is not geometry evidence. Do not use synthetic image generation to hide, repair, or validate reconstruction errors. When the user explicitly requests a concept visualization later, keep it clearly separate from measured/reconstructed current-state geometry and ground it in the original source view.
