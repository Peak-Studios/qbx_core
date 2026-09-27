local resourceName = GetConvar('qbx:inventoryResource', 'peak-qb-inventory')

local function getBackend()
    if GetResourceState(resourceName) ~= 'started' then
        error(('%s must be started before qbx_core can load or save player inventories'):format(resourceName))
    end

    return exports[resourceName]
end

local function waitForBackend()
    local timeout = GetConvarInt('qbx:inventoryStartTimeout', 30000)
    if timeout < 1000 then timeout = 30000 end
    local startedAt = GetGameTimer()

    while GetResourceState(resourceName) ~= 'started' do
        if GetGameTimer() - startedAt >= timeout then
            error(('%s did not start within %dms; refusing to load a player without its inventory backend'):format(resourceName, timeout))
        end
        Wait(100)
    end

    return exports[resourceName]
end

return {
    resourceName = resourceName,

    load = function(source, citizenid)
        return waitForBackend():LoadInventory(source, citizenid)
    end,

    save = function(identifier, offline)
        return getBackend():SaveInventory(identifier, offline)
    end,

    addItem = function(source, item, amount, slot, metadata)
        return getBackend():AddItem(source, item, amount, slot, metadata)
    end,

    removeItem = function(source, item, amount, slot)
        return getBackend():RemoveItem(source, item, amount, slot)
    end,

    getItemBySlot = function(source, slot)
        return getBackend():GetItemBySlot(source, slot)
    end,

    getItemByName = function(source, item)
        return getBackend():GetItemByName(source, item)
    end,

    getItemsByName = function(source, item)
        return getBackend():GetItemsByName(source, item)
    end,

    getTotalWeight = function(items)
        return getBackend():GetTotalWeight(items)
    end,

    getSlotsByItem = function(items, item)
        return getBackend():GetSlotsByItem(items, item)
    end,

    getFirstSlotByItem = function(items, item)
        return getBackend():GetFirstSlotByItem(items, item)
    end,

    useItem = function(source, item)
        return getBackend():UseItem(item, source)
    end,

    clear = function(source, filterItems)
        return getBackend():ClearInventory(source, filterItems)
    end,

    set = function(source, items)
        return getBackend():SetInventory(source, items)
    end,

    getItemCount = function(source, itemName)
        local items = getBackend():GetItemsByName(source, itemName) or {}
        local count = 0
        for i = 1, #items do
            count = count + (tonumber(items[i].amount) or 0)
        end
        return count
    end,

    hasItem = function(source, items, amount)
        local function has(itemName, required)
            return require 'modules.inventory'.getItemCount(source, itemName) >= required
        end

        amount = tonumber(amount) or 1
        if type(items) == 'string' then return has(items, amount) end
        if type(items) ~= 'table' then return false end

        for key, value in pairs(items) do
            local itemName = type(key) == 'number' and value or key
            local required = type(key) == 'number' and amount or (tonumber(value) or amount)
            if type(itemName) ~= 'string' or not has(itemName, required) then return false end
        end
        return true
    end,
}
