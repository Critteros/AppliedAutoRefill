-- Applied system auto reffiler by Critteros (v.1)

-----Constants------

--Adress of ME network with items to auto-refill
local dummySystemAdress = "99a69246-9fcd-42c1-8908-f60abdae86b4"

--Adress of main ME network with crafting capabilities
local mainSystemAdress = "afab95b0-7e40-4c55-9c08-5724d436c006"

--Constant that defines in % how many items will be requested at once 
local craftingConstant = 0.45

--------------------

--[[
Structure:

Items = {
	{Name, ID, Damage, Amount}
}


--]]



local component = require("component")
local dummySystem = component.proxy(dummySystemAdress)
local mainSystem = component.proxy(mainSystemAdress)


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



local function getStoredItems(NetworkObject)
	
	local AppliedData = NetworkObject.getItemsInNetwork()
	local Items = {}
	local Item = {}
	local NumberOfItems = AppliedData["n"]

	if NumberOfItems == 0 then error("Dummy network has no Items") end
	
	for i=1,NumberOfItems,1 do
		
		Item["Name"] = AppliedData[i]["label"]
		Item["ID"] = AppliedData[i]["name"]
		Item["Damage"] = AppliedData[i]["maxDamage"]
		Item["Amount"] = AppliedData[i]["size"]

		table.insert(Items, deepcopy(Item))
		
		

	end
	
	return Items, NumberOfItems

end
Items,NumberOfItems = getStoredItems(dummySystem)

for x,y in pairs(Items) do print(x,y["Name"],y["ID"],y["Damage"],y["Amount"]) end
print(NumberOfItems)






