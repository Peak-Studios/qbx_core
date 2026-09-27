![image](.github/images/banner.jpg)


_<p align="center">"And then there was Qbox"</p>_


# qbx_core

qbx_core is a framework created on September 27, 2022, as a successor to qb-core and continues the development of a solid foundation for building easy-to-use, performant, and secure server resources.

Want to know more? View our [documentation](https://qbox-project.github.io/)

# Features

- **Bridge layer provides Backwards compatibility with Most QB Resources with 0 effort required**
- Built-in multicharacter
- Built-in multi-job/gang
- Built-in queue system for full servers
- Persistent player vehicles
- Export based API to read/write core data

## Modules
The core makes available several optional modules for developers to import into their resources:
- Hooks: For developers to provide Ox style hooks to extend the functionality of their resources
- Logger: Can log to either discord, or Ox's logger through one interface
- Lib: Common functions for tables, strings, math, native audio, vehicles, and drawing text.

# Dependencies

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [peak-qb-inventory](https://github.com/Peak-Studios/peak-qb-inventory) (set `qbx:inventoryResource` to override its resource name)

## Replacing ox_inventory

This qbx_core build uses `peak-qb-inventory` as the authoritative item backend. Player item data stays in `players.inventory`; Qbox money accounts stay in `players.money` and are not transferable inventory items.

### Import item definitions

Keep `ox_inventory` installed and started for this step. From the server console, run:

```text
qbx_importOxItems
```

This writes Ox item, weapon, component, and ammo definitions it can read to `shared/items_imported.lua`. It keeps existing Qbox definitions when names overlap, so compare those definitions with Ox for weight, stack behavior, and metadata before migrating. Review and keep the generated file with your server config. The importer does not convert Ox use callbacks or client behavior; port those manually to Qbox/QB item callbacks and check each item's images and use behavior. Then restart `qbx_core` and `peak-qb-inventory` so both resources load the catalog.

### Migrate saved inventories

With Ox and Peak available, stop player sessions so Qbox cannot save stale inventory data over the migration. Set the validation limits to match `peak-qb-inventory/config/config.lua` if you changed its defaults, then run from the server console:

```text
set qbx:peakStashMaxSlots 100
set qbx:peakMaxSlots 111
set qbx:peakMaxWeight 120000
qbx_migrateOxInventory
```

The defaults match Peak's default stash and player slot/weight limits. The migration exits when any player session is connected and temporarily rejects new connections until it finishes. It backs up each existing source table to uniquely named `qbxpk_mig_<run-id>_*` tables, converts `players.inventory` to QB item records, and copies non-empty Ox stashes and vehicle trunks/gloveboxes into Peak's `inventories` table. It keeps the Ox rows in place. Vehicle storage is read from Qbox's `player_vehicles` table; `id`, `plate`, `trunk`, and `glovebox` columns must exist. Ox normally adds the last two columns when it starts. Custom vehicle table configurations need a separate migration. The migration validates JSON, item definitions, slots, player weight, duplicate vehicle plates, target key collisions, and account-item stacks before changing data. A legacy money/account item is stripped only when its total exactly matches the corresponding `players.money` balance; mismatches and unknown items stop the migration for manual review. Re-running creates new backups and accepts target rows only when their contents already match.

Migrated stash IDs use a length-prefixed format. Get the ID from core so old stash registrations can be ported to Peak's `CreateInventory`/`OpenInventory` exports:

```lua
local stashId = exports.qbx_core:GetMigratedStashId(owner, stashName)
exports['peak-qb-inventory']:CreateInventory(stashId, {
    label = stashLabel,
    maxweight = stashMaxWeight,
    slots = stashSlots,
})
exports['peak-qb-inventory']:OpenInventory(source, stashId, {
    label = stashLabel,
    maxweight = stashMaxWeight,
    slots = stashSlots,
})
```

The helper returns `oxstash:<owner-byte-length>:<owner>:<name-byte-length>:<name>`; a `nil` owner is encoded as an empty owner. Vehicle inventory keys are `trunk-<trimmed uppercase plate>` and `glovebox-<trimmed uppercase plate>`. Port scripts that register or open Ox stashes before removing Ox, then remove `ox_inventory` from the resource start list after reviewing the backups and migration output.

#

⚠️We advise not modifying the core outside of the config files⚠️

If you feel something is missing or want to suggest additional functionality that can be added to qbx_core, bring it up on the official [Qbox Discord](https://discord.gg/qbox)!

Thank you to everyone and their contributions (large or small!), as this wouldn't have been possible.
