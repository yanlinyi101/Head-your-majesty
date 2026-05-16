# Phase 1 Playtest Checklist

Run three full 3-minute matches. Record answers immediately after each match.

## Match Setup

- Build: local Godot editor or headless-export run
- Input: keyboard and mouse
- Mode: 1 player vs 1 BOT
- Arena: small multi-level graybox
- Head: king head only

## Per-Match Checks

- [ ] The king head is visible dropping from above the center within the first 5 seconds.
- [ ] The player understands within 30 seconds that wearing the king head scores points.
- [ ] The BOT moves toward the loose king head.
- [ ] The BOT chases the player when the player wears the head.
- [ ] A strong collision can knock the king head off the carrier.
- [ ] A fall or tumble can occasionally knock the king head off without feeling random.
- [ ] The head rolls down at least one ramp or step path and remains reachable.
- [ ] The loop of wear, score, knockoff, roll, chase, and re-wear completes at least 3 times.
- [ ] The match logs at least 2 reversal events.
- [ ] The final result shows a winner or tie after 3 minutes.

## Notes

Record one sentence for each issue:

- What was confusing?
- What caused the funniest reversal?
- What made the head hard to see or chase?
- Did the carrier feel too safe, too weak, or about right?
- Did the BOT feel present without feeling unfair?
