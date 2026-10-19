# Expansion: colonization and conquest

## Implemented on 18 October 2026

The first colonization loop is playable locally. No shared world or Game Center season is claimed as implemented.

- A capital and at most two colonies. The second colony is more demanding than the first.
- First colony requirements: Hall 5, Academy 3, Expedition Quay 2, Warehouse 3. Warehouse capacity is 1,800 per resource.
- Navigation research: 300 wood / 250 amber / 300 food, 30 minutes, completed once.
- A civilian settler team: 400 wood / 150 amber / 500 food, one hour, consumed on departure. These are expedition specialists rather than new combat units.
- First foundation: 1,800 wood / 1,200 amber / 1,500 food. Second foundation: 3,600 / 2,400 / 3,000, requiring Hall 8, Academy 5, Quay 3, Warehouse 7 (capacity 3,800).
- Five soldiers of a chosen available type escort the team. They leave the source garrison immediately, still count toward its recruitment cap while at sea, then become the colony garrison. Founding voyages do not simulate combat.
- Travel takes 30 minutes plus 30 seconds per Manhattan tile from the capital. Departure is confirmed and irreversible; supplies are committed and cannot be refunded.
- Sites must be land, at least eight tiles from owned settlements and six from existing neighboring territory. Suggestions provide accessible alternatives to selecting a map tile.
- Refuges are at least 35 Manhattan tiles from every original neighboring capital. The refuge designation is fixed at foundation and prevents starting or advancing defensive campaigns there. There are currently no automatic offline attacks anywhere.
- Neighbor expansion respects a buffer around owned and pending settlement sites.
- Colonies start with 200 wood, 100 amber, 200 food, three level 1 fields, a Hall and the five escorts. This starting stock is included in the founding supplies.
- Specialization is permanent in this prototype: forest colony increases wood output by 20 percent, amber trading post increases amber output by 20 percent, outpost adds 20 permanent defense points. Production bonuses currently round down to whole hourly units.
- Every village has separate resources, buildings, fields, jobs, research and army. All production and timed jobs continue while another settlement is selected or the app is closed. Arrivals are settled exactly once.
- A menu switches the active settlement; owned markers also appear on the world map. Founding voyages appear in Missions.
- The companion points to Colonization after the initial milestones and disappears once a second village actually exists.

Persistence remains in the existing village save key. The active village contains at most two flat inactive village snapshots; nested domains, duplicate coordinates and invalid voyages are rejected. Legacy villages migrate without resetting progress. Domain and actual session checks cover departure, offline arrival, relaunch, independent economies and the three-settlement limit.

These costs and times are an initial tuning baseline, not validated retention targets.

## Supply shipments — implemented

Missions and another owned village selected on the map open the supply form. A source Expedition Quay is required; the destination can receive supplies before building its own quay. The player chooses wood, amber, food and an escort. Total cargo is bounded by available stock and the selected troops’ carrying capacity including the departure quay and people bonuses.

Supplies and troops leave immediately. Travel takes 60 seconds plus 10 seconds per Manhattan tile one way. Cargo unloads at arrival; soldiers return to the source after the round trip. Internal supply routes have no combat or extra resource fee in this version. One unfinished supply shipment is allowed per source village.

Resources exceeding destination storage remain in the shipment ledger and unload as space becomes available. Escorts return on schedule even when cargo is waiting; another departure from that source becomes available only after both return and full unloading. Completed shipment summaries remain visible until replaced by the next shipment.

Delivery, storage escrow and escort return persist through switching villages, app closure and relaunch. Offline processing splits at delivery, return and building-completion times so incoming resources are credited before subsequent production. Simultaneous deliveries use stable geographic source order. Migration to save version 17 preserves older villages.

## Remaining work

Conquest chiefs, occupation, the Grand Lighthouse objective and Game Center seasons remain unimplemented. The historical ten-village Wonder requirement is superseded by the agreed small-domain direction; its replacement victory rules still need implementation.

## Proposed conquest loop — not yet approved as final rules

A conquest chief establishes a foothold after the player's expedition defeats a simulated rival's garrison. This creates an announced occupation stage, not immediate ownership. The player must hold the foothold against a visible counterattack before annexation is confirmed. The choices are how much escort to commit, whether the home harbor remains defended, and whether the capture is worth its supply costs.

This proposal uses a maritime landing and defense decision. It does not introduce a copied loyalty percentage, repeated loyalty-reduction attacks or arbitrary persuasion rolls. Exact chief consumption, retreat rules, occupation timing, supply costs and consequences of defeat remain to be decided before implementation.

Prototype against bots first. Ownership transfers involving real players depend on the future authoritative shared world and separately agreed PvP protections. This design does not decide destruction, permanent player losses or ways to bypass attack limits.

## Conquest statistics and future validation

All combat choices expose attack, defense and carrying capacity. Weapon upgrades affect attack and defense; transport includes expedition bonuses. A future chief needs its own balanced statistics and recruitment path once its occupation mechanic actually works. No chief recruitment or annexation is currently offered.

Next: a foothold prototype with an announced counterattack and tested retreat rules. Game Center competition follows a separately defined victory objective.
