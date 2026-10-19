# Village companion

## First implementation

- A floating companion avatar sits above bottom navigation. A dismissible first hint invites the player to open a compact conversation over the village.
- Each people has an identity: Maëlle for Humans, Nério for Reef Folk, Sylve for Marsh Elves.
- Dedicated transparent portraits are integrated as GuideMaelle, GuideNerio and GuideSylve. Generation prompts are retained in COMPANION-ART-PROMPTS.md.
- Advice uses actual village progress: first field, academy, research, training grounds, recruitment, expedition.
- Quick replies cover the next step, common blockers and the first raid. Show me opens a suitable plot/building detail directly and attaches TipKit to the actual upgrade, build, research or training control. The raid path points to preparation and then the send command.
- The conversation can be minimized. Up to eight question/answer pairs remain while this game view is active; no conversation is written to the village save.
- The panel explicitly labels free-form Core AI chat as upcoming; deterministic replies are not presented as model-generated answers.
- French and English text use the existing Localizable catalog. No blocking introduction is added.

## Local chat direction

Use **Core AI**, as explicitly requested, without paid inference APIs. This is not implemented yet.
Apple documents on-device inference with no token charges: https://developer.apple.com/core-ai
The framework is present in the installed iOS 27.1 device SDK and the app targets iOS 27.

Core AI requires a supplied language model. Before adding the runtime:

1. Select a compact French/English instruction model with redistribution rights appropriate for the game.
2. Measure its installed size, RAM, latency and battery use on the oldest supported physical iPhone.
3. Decide whether to bundle the weights or download them optionally. Downloads can incur hosting/transfer costs, even when inference is local.
4. Provide the companion's personality, verified game rules and current village facts as context. Advice cannot change resources or launch actions.
5. Test questions about costs, storage, research, combat and unavailable features; prevent invented rules from replacing the deterministic guidance.
6. Keep the advice sheet available when the model cannot load. Do not label scripted advice as an AI conversation.

Official model recipes and Swift runtime utilities: https://github.com/apple/coreai-models

## Remaining UX work

- Check portrait readability in the small companion button on physical devices.
- Check precise TipKit anchors on physical devices, including small screens and large text sizes.
- Live waiting states and economy blockers, rather than progression-only advice.
- Free-form local chat input, model lifecycle, cancellation and device verification.
- Visual checks on iPhone, iPad, VoiceOver and accessibility text sizes.

## Main objectives and retirement

The six main objectives are: finish one field upgrade, build the academy, research one unit, build the training grounds, finish recruitment, and resolve a first raid. A loss still completes the raid objective; departure alone does not.

Observed objectives are accumulated in the village save as an optional set, preserving compatibility with saves that do not contain this field. Existing field/building/unit progress and legacy raid reports count. Completion is monotonic: losing troops or replacing the last raid report cannot undo a recorded objective. These six objectives complete the initial chapter only. The companion remains available afterward. The confirmed retirement milestone is the actual foundation of the player’s second village. Colonization and multiple player villages are not implemented yet, so no retirement trigger is currently active. Do not infer a second village from an enemy settlement, a new save, or first-raid completion. A fresh village begins its own progression.

Domain checks cover initial-chapter completion, a raid in flight, return, persisted milestones and legacy saves. Session checks verify that the usual save/relaunch flows still work.

## Core AI candidate selected — 18 October 2026

First candidate: **Qwen/Qwen3-0.6B**, with Apple's iOS export recipe and its mixed 4-bit/8-bit compression. This is a prototype selection, not a validated shipping model. The model card lists Apache 2.0 licensing. Retain the model license and required attribution when distributing weights.

- Apple recipe: https://github.com/apple/coreai-models/tree/main/models/qwen3
- Model card: https://huggingface.co/Qwen/Qwen3-0.6B
- Initial evaluation target: 2,048-token context and replies capped at 128 tokens, without extended reasoning.
- Alternative to compare only if French accuracy is insufficient: Qwen3 1.7B, also listed in Apple's iOS recipe; size and memory costs must be measured before choosing it.
- Do not infer installed size or runtime RAM directly from parameter count. Apple's recipe explicitly warns that iOS memory limits can be exceeded.
- Core AI supplies inference; the official Apple Swift utilities also expose a Foundation Models session adapter. This would run our supplied Core AI model, not silently switch to Apple's system model. The app currently uses neither runtime nor adapter.

No model weights have been added or downloaded, and no chat is presented as working. Device discovery found only simulated iPhones/iPads, so real-device Core AI latency, RAM, battery and French answer quality remain unmeasured. Use COREAI-EVALUATION.md to run the acceptance session when a physical device and exported model are available.

## Colonization integration — 18 October 2026

After the six initial milestones, the companion opens the real Colonization screen. It retires only after the second owned village is created on expedition arrival. Research, preparation or departure alone do not retire it. This supersedes the earlier note that retirement awaited a founding system.
