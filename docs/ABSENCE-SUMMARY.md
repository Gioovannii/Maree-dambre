# Return summary

After an offline update of at least five minutes, a non-blocking “While you were
away” banner appears above the resource bar. Tapping it opens a scrollable sheet.
There is no automatic modal or additional notification.

The summary compares the state immediately before and after the normal domain
update. It covers the selected village and all inactive settlements:

- Net stock changes across the domain, including retained production, incoming
  rewards, deliveries, founding stocks and plunder. These are explicitly not
  total production and may be negative.
- Completed building/field upgrades, weapon/doctrine research and trained recruits.
  Recruits trained does not promise that every recruit survived a later battle.
- New non-imported reports, with up to three previews and access to Messages.
- Newly founded villages and the number of resource stores currently at capacity.

The normal domain update and save remain the only authority. Reading or closing
the summary grants nothing and leaves mailbox read state untouched. Closing the
sheet clears the transient summary. Ordinary ticks do not replace it; another
absence of at least five minutes replaces it with that absence’s summary. The
summary is not persisted: reopening immediately cannot replay it because the
updated game checkpoint has already been saved. No save schema migration is
needed. Corrupt/unreadable saves do not produce a summary.

Durations reflect the interval since the last simulation checkpoint, not an
analytics session timer. The summary excludes historical reports imported during
migration and reports already present before the offline update. Mailbox retention
limits still apply. Future work may preserve a historical activity journal, but
this feature does not create one.

Checks cover real offline completion in multiple villages, threshold boundaries,
negative stock changes, full stores, imported/deduplicated reports, actual session
relaunch, dismissal without rewards/read changes, native French/English strings,
simulator compilation and iPhone/iPad visual captures.
