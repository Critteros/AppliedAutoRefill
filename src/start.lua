-- Applied system auto reffiler by Critteros (v.1)

-----Constants------

--Adress of ME network with items to auto-refill
local dummySystemAdress = "99a69246-9fcd-42c1-8908-f60abdae86b4"

--Adress of main ME network with crafting capabilities
local mainSystemAdress = "afab95b0-7e40-4c55-9c08-5724d436c006"

--Constant that defines in % how many items will be requested at once 
local craftingConstant = 0.45

--Names of CPUs that you want to craft with 
local cpus = {"Eve", "Angela"}
--------------------

--[[
Structure:

Items = {
	{Name, ID, Damage, Amount}
}


--]]





local function main()
	local component = require("component")
	local dummySystem = component.proxy(dummySystemAdress)
	mainSystem = component.proxy(mainSystemAdress)
	
	
	Items,NumberOfItems = getStoredItemsInDummy(dummySystem)

	--debugShow(Items)
	local Quque = getItemsInMain(mainSystem,Items)
	--debugShow(Quque)
	
	print("------------------")
	
	Control,Quque = Craft(mainSystem,Quque)
	
	print("------------------")
	--debugShow(Quque)
	--print(Control.isCanceled())
	--print(Control.isDone())


	
	


end

--Input: Netowrk proxy for applied Output: Containts of that network
function getStoredItemsInDummy(NetworkObject)
	
	local AppliedData = NetworkObject.getItemsInNetwork()
	local currItems = {}
	local NumberOfItems = AppliedData["n"]

	if NumberOfItems == 0 then error("Dummy network has no Items") end

	for i=1,NumberOfItems,1 do
			
		local Name = AppliedData[i]["label"]
		local ID = AppliedData[i]["name"]
		local Damage = AppliedData[i]["damage"]
		local Amount = AppliedData[i]["size"]

		table.insert(currItems,{
				ID = ID,
				Damage = Damage,
				Name = Name,
				Amount = Amount
			})
			
			
	end
	
	return currItems, NumberOfItems

end

function Craft(NetworkObject, Quque)
	print(type(Quque[1]))
	if type(Quque[1]) ~= 'nil' then

		local AppliedData = NetworkObject.getCraftables({
			["label"] = Quque[1]["Name"],
			["name"] = Quque[1]["ID"],
			["damage"] = Quque[1]["Damage"]
		})
		if AppliedData["n"] == 0 then io.write('No given recipe found for "', Quque["Name"],'". \n' )
		elseif  AppliedData["n"] == 1 then
			local currCpu = getCpu(mainSystem)
			if type(currCpu) == 'string' then
				local craftingObject = AppliedData[1].request(Quque[1]["ToCraft"],_,currCpu)
				table.remove(Quque,1)
				return craftingObject, Quque
			else error("currCpu type not string") end

		else error("An error has occured when pulling recipes from main netowrk") end
	end


end


function getItemsInMain(NetworkObject, Filter)
	local quque = {}

	for _,value in pairs(Filter) do
		local AppliedData = NetworkObject.getItemsInNetwork({
			["label"] = value["Name"],
			["name"] = value["ID"],
			["damage"] = value["Damage"]
		})
		if AppliedData["n"] == 0 then
			io.write('Item "',value["Name"],'" not found in main netowrk \n')
		elseif AppliedData["n"] == 1 then
			
			if AppliedData[1]["size"] < value["Amount"] then 
				local maxCraftsize = value["Amount"] * craftingConstant
				local delta = value["Amount"] - AppliedData[1]["size"]
				if delta > maxCraftsize then delta = maxCraftsize end
				delta = math.ceil(delta)

				table.insert(quque,{
					Name = value["Name"],
					ID = value["ID"],
					Damage = value["Damage"],
					ToCraft = delta
				})
			end


		else error("Error has occured when pulling list from main network") end
		
	end
	return quque


end

--Returns first avaible cpu form the desired list
function getCpu(NetworkObject)
	local cpuInNetwork = NetworkObject.getCpus()

	for key,value in pairs(cpuInNetwork) do
		if key ~= "n" then
			for _,cpuName in pairs(cpus) do
				if (value["name"] == cpuName) and (value["busy"] == false)  then
					return value["name"]
			
				end
			end
		
		else return nil end
	end
end


--Prints out tables for debbuging purpose
function debugShow(Object)
	
	--for x,y in pairs(Object) do print(x,y["Name"],y["ID"],y["Damage"],y["Amount"]) end
	
	for key,value in pairs(Object) do
		if (type(value) == 'nil') or (type(key) == 'nil') then break
		elseif type(value) == 'table' then 
			io.write(tostring(key))
			io.write("\t")
			io.write(debugShow(value))
			io.write("\n")
			
		else
			if type(key) == 'string' then
				io.write(key)
				io.write(":"," ")
			elseif type(key) == 'number' then
				io.write(tostring(key))
				io.write(" ")
			end
			io.write(tostring(value))
			io.write("\t")
		end
	end
end

main()









