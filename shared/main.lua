local qbShared = {}
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Locations = require 'shared.locations'
qbShared.Vehicles = require 'shared.vehicles'
qbShared.Weapons = require 'shared.weapons'
qbShared.Items = require 'shared.items'
for name, item in pairs(require 'shared.items_imported') do
    if qbShared.Items[name] == nil then qbShared.Items[name] = item end
end

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
    qbShared.VehicleHashes[v.hash] = v
end

return qbShared
