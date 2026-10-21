# Hero support and map travel

Raid preparation offers an explicit hero toggle. A chosen hero can join only when
not on a personal mission or another raid anywhere in the domain. Support adds
two attack points per hero level, capped at twenty, frozen at departure and used
by the preview and resolution. The hero does not count toward the troop cap and
returns even if all accompanying troops are lost. No hero wound or death system
is introduced.

New raids award combat XP only when the hero accompanied them: twenty on victory,
five on defeat, with the existing neighbor-per-UTC-day limit. XP is credited once
through the persisted mailbox reward marker. Legacy reports with no participation
field retain their old rules. Defense and colony XP rules are unchanged.

Raid orders store departure time, participation and support strength. Domain
validation rejects simultaneous hero raids and a personal voyage during a hero
raid. Switching villages does not free the hero. Old raids remain loadable.

The map shows all active domain raids and the hero's traveling missions, with
distinct paths, moving markers, outbound/return phases, countdowns and locate
actions. The midpoint represents the destination; reports and rewards still
resolve at the original return deadline. Map movement never drives game logic.
Personal missions have stable illustrated destinations derived from their origin
and mission kind. Boat repair stays at the port and has no moving map marker.
Routes are straight illustrative lines, not terrain-aware pathfinding.

Reduced Motion lowers marker updates to once per second. Snapshot captures freeze
the trip at one quarter of the journey and keep matching progress indicators.
Capture modes `worldTravel` and `heroSupport` exercise separate and accompanied
voyages without overwriting screenshot references.
