# Living Domaine d’Ambre preview

Open `http://127.0.0.1:3003/preview.html` for automatic looping playback and the Pause/Resume button. The local server serves this directory.

`index.html` is a six-second HyperFrames composition at 887 × 1774 px. Its GSAP timeline stays paused; HyperFrames seeks through it for captures, while `preview.html` drives the looping preview.

The sea uses gentle distortion and moving highlights, constrained by a mask that protects the coast, boats, and interface. Five inhabitants have small local movements anchored at their feet. These are stationary gestures derived from an illustration, rather than walking character animations.

The corrected preview passed `hyperframes check` without errors. The single-scene structure warning and masked-image overflow information do not affect the final framing. Captures are in `proof-v2/`. Pixel comparisons confirmed a fixed HUD and animated water and workers.

This preview is independent of the native app, and no video was exported from this project. The native rendering adopted later is documented in [Living domain](../../docs/LIVING_DOMAIN.md). Proof captures are reproducible local files excluded from the repository.

To restart the player from this directory, run `python3 -m http.server 3003 --bind 127.0.0.1`, then open `http://127.0.0.1:3003/preview.html`.
