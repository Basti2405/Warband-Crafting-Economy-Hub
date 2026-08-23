# Warband Crafting & Economy Hub

**A catalogue across the whole warband: which character can craft what, and
where the materials are.**

*[Deutsche Fassung](README.md)*

> The core add-on is called **WarbandForge** in your AddOns folder and its
> slash command is `/wf`. WoW requires the folder and `.toc` name to match,
> and it tolerates neither `&` nor brackets in them.

TSM is too much for many casual players; simple inventory add-ons do not
model professions at all. This add-on answers exactly two questions — and
stops there.

## Status: scaffold

**This is not a finished add-on yet.** It loads, it does not crash, and it
says honestly that it has not recorded anything. The architecture holds:
22 logic tests, all green. What is built and what is not is documented in
[`Planung/`](Planung/) (in German).

| Works | Missing |
|---|---|
| Core loads, module system holds | Recording recipes |
| Storage (account-wide, timestamped) | Material check |
| Profession scan with retry | The "who can craft X?" view |
| Three module scaffolds with `## Dependencies` | Module logic |
| `/wf`, `/wf doctor` | |

## Structure

Four standalone add-ons in one repository:

```
WarbandForge/                  Core
WarbandForge_WorkOrders/       Module – work orders
WarbandForge_Housing/          Module – housing
WarbandForge_PriceSync/        Module – prices
```

Every module declares `## Dependencies: WarbandForge` and can be **disabled
individually**. If you do not need prices, the price code is not in memory.
The core knows no module by name.

## Commands

| Command | Effect |
|---|---|
| `/wf` | Show or hide the window |
| `/wf doctor` | Self-check – start here when something is wrong |
| `/wf help` | All commands |

## What it can*not* do

- **It only sees what the client knows.** What sits on another character is
  known because that character stored it at its last login — not because
  anything is queried live. An alt untouched for weeks shows the state of
  weeks ago. That is why every entry carries the time it was recorded.
- **The guild bank only if it was open.** WoW does not deliver its contents
  in the background.
- **It does not buy or craft.** Both are protected actions.
- **It does not scan the auction house.** The price module reads an existing
  price add-on; if none is present, it disables itself.

## Development

```bash
tools/junction.cmd    # links every add-on folder into your AddOns directory
./tools/test.sh       # syntax, .toc cross-check and logic tests (builds Lua 5.1)
```

## Licence

MIT, see [LICENSE](LICENSE).
