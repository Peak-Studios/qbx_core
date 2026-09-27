local qbShared = {}
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Locations = require 'shared.locations'
qbShared.Vehicles = require 'shared.vehicles'
qbShared.Weapons = require 'shared.weapons'
qbShared.Items = require 'shared.items'
for name, item in pairs(require 'shared.items_imported') do
    if qbShared.Items[name] == nil then qbShared.Items[name] = item end
end

local accountItemAccounts = { money = 'cash', cash = 'cash' }
local accountItems = { money = true, cash = true }
local ok, configuredAccounts = pcall(json.decode, GetConvar('inventory:accounts', '["money"]'))
if ok and type(configuredAccounts) == 'table' then
    for _, itemName in ipairs(configuredAccounts) do
        if type(itemName) == 'string' and itemName ~= '' then
            itemName = itemName:lower()
            accountItems[itemName] = true
            accountItemAccounts[itemName] = itemName == 'money' and 'cash' or itemName
        end
    end
end

-- Qbox money balances are authoritative account data. Never expose account
-- aliases as ordinary transferable inventory items.
for itemName in pairs(accountItems) do
    qbShared.Items[itemName] = nil
end
qbShared.AccountItems = accountItems
qbShared.AccountItemAccounts = accountItemAccounts

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
    qbShared.VehicleHashes[v.hash] = v
end

return qbShared
