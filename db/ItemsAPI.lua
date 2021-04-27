local addon, ns = ...
local items = ns.items

local function hasValue(array, value)
    for i = 1, #array do
        if array[i] == value then
            return i
        end
    end
    return nil
end


-- Returns all the appearances for the given slot/subclass.
function ns.GetSubclassAppearances(slot, subclass)
    assert(type(slot) == "string", "'slot' is mandatroy and must be 'string'.")
    assert(type(subclass) == "string", "'subclass' is mandatroy and must be 'string'.")
    local slotData = items[slot] == nil and items["Armor"][slot] or items[slot]
    return slotData[subclass]
end


-- Returns a table {[itemId] = "itemName",} of other items with the same appearance
-- (display id) as the item with the given id including the given id.
-- 'subclass' can be nil. Also returns 'subclass' as second value if nil.
function ns.GetOtherAppearances(itemId, slot, subclass)
    assert(type(itemId) == "number", "'itemId' is mandatroy and must be integer.")
    assert(type(slot) == "string", "'slot' is mandatroy and must be 'string'.")
    assert(subclass == nil or type(subclass) == "string", "'subclass' must be 'string' or 'nil'.")
    local slotData = items[slot] == nil and items["Armor"][slot] or items[slot]
    if subclass ~= nil then
        local subclassData = slotData[subclass]
        for _, data in pairs(subclassData) do
            local ids = data[1]
            local names = data[2]
            local index = hasValue(ids, itemId)
            if index ~= nil then
                return ids, names, index, subclass
            end
        end
    else
        for subclass, subclassData in pairs(slotData) do
            for _, data in pairs(subclassData) do
                local ids = data[1]
                local names = data[2]
                local index = hasValue(ids, itemId)
                if index ~= nil then
                    return ids, names, index, subclass
                end
            end
        end
    end
end