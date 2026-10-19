# Mailbox and navigation

Implemented on 18 October 2026. The navigation has five destinations: Resources, Town, World, Missions and Messages. The selected destination is highlighted and Messages carries a shared unread badge across all owned villages. Accessibility text sizes use a vertical navigation layout and stacked mailbox controls.

The local inbox collects council messages and immutable event reports:

- Welcome when choosing a people.
- Attack report when a raiding army returns.
- Defense report when an assault is resolved through the existing coastal campaign.
- Maritime contract report when its escort returns.
- Colony foundation after actual arrival.
- Internal supply delivery after all cargo has unloaded. Escort return remains tracked by the supply mission.

Opening a message marks it as read. Filters show all, unread, reports or messages. Mark-all-read spans every owned village. Details open in a modal sheet; attack reports retain their forces, troop losses and stored loot. Reading a report never claims a reward, credits resources, advances a campaign or repeats a delivery.

Each village stores at most its latest 100 messages. IDs include the world seed, source coordinate and an event identity; repeated processing of a completed order does not create duplicates. Event facts are stored rather than translated sentences. Dates and read status persist, and labels follow French or English app localization.

Save version 18 imports the latest structured reports present in older villages once. Older reports lack reliable event timestamps and are displayed as earlier reports, rather than assigning them an asserted battle time. Unstructured legacy text reports remain available in their existing army panel.

The mailbox currently contains local game correspondence and event reports. It does not send or receive private messages between human players. Scheduled automatic attacks and changing capitals are separate future features.

Domain and actual session checks cover event history, deduplication, read state, switching villages, legacy import, retention and invalid saved mail. UI snapshots cover the inbox and attack-report modal.
