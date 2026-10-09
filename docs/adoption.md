# Adoption

What this project has taken on from the `@tshelburne` plugin marketplace, in the
vocabulary of **project-architecture:adoption-state** — `adopted`, `intended`,
`ignored`, `unsure`, `all`.

This repository declares no plugins — `.claude/settings.local.json` is
permissions only, with no `hooks` key at all, which is what the item below is
about.

**Seeded from a Tier A sweep and nothing wider:** the six baseline packages —
`domain`, `cfg`, `dev-ports`, `dev-proxy`, `ops`, `surfaces`. Every skill that
pass had no evidence about is left **unlisted** on purpose rather than guessed
at. Unlisted already means *ask once*, so this file is safe as it stands and is
completed by the conversation **adoption-state** describes.

## project-architecture
Ignored: all — no TypeScript in this repository; falsified the day one arrives

## dev-environment
Intended: execution-environment — copy starters/bash/session-start. Issues are
          disabled on this fork, so the drafted issue rides in the pull request
          that added this file.

Anything not listed is not in force. Say what it would give us.
