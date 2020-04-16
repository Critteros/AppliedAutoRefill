-- Applied system auto reffiler by Critteros (v.1.5)

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
--------------------


--------Code-----------------------------

--------Proxies--------
local component = require("component") --Importing component library for OC integration
local thread = require("thread")
local gpu = component.gpu
local dummySystem = component.proxy(dummySystemAdress) --Creating a reference object for dummy netowrk
local mainSystem = component.proxy(mainSystemAdress) --Creating a reference object for main netowrk
-----------------------

-----Main Function-----
local function main()
    os.execute("cls")
    print("Starting...\n")
    print("------------------------------------")
    
    
    while true do
        gpu.setForeground(0xFFFFFF) -- White
        local threadList = {}
        local itemList = GetStoredItems()
        local queque = CreateQueque(itemList)
    
        if queque ~= nil then 
            for _, value in pairs(queque) do
            
                io.write("Network contains ")
                gpu.setForeground(0xCC24C0) -- Purple-ish
                io.write(value.Amount)
                gpu.setForeground(0xFFFFFF) -- White
                io.write(" items with label ")
                gpu.setForeground(0x00FF00) -- Green
                io.write(value.Name, "\n")
                gpu.setForeground(0xFFFFFF) -- White
        
                io.write(" Trying to Craft: ")
                gpu.setForeground(0xFF0000) -- Red
                io.write(value.Delta, "\n")
                gpu.setForeground(0xFFFFFF) -- White
        
        
                table.insert(threadList, thread.create(HandleCrafting,value))
                os.sleep(2)
        
            end
            thread.waitForAll(threadList)
            print("------------------------------------")

        else
            gpu.setForeground(0x808080) -- Gray
            print("No action needed, skipping")
            print("------------------------------------")

        end
        
        os.sleep(5)
    end

   
    
end

-----------------------


----Crafting Handler----
function HandleCrafting(entry)
    
    local toCraft = entry.Delta
    local token = entry.Token
    local noCpu = true
    local cpuName = nil

    while noCpu do
        cpuName = GetCpu()
        if cpuName ~= nil then
            noCpu = false
        end
        os.sleep(2)
    end
    --print(cpuName)
    local status = token.request(toCraft, nil, cpuName)

    
    while (status.isCanceled() == false) and (status.isDone() == false) do
        os.sleep(2)
    end

    if status.isCanceled() == true then
        gpu.setForeground(0xFF0000) -- Red
        io.write("  !!!")
        gpu.setForeground(0xFFFFFF) -- White
        io.write("Not enough resources to craft: ")
        gpu.setForeground(0xFF0000) -- Red
        io.write(entry.Name, "\n")
        gpu.setForeground(0xFFFFFF) -- White
   
    else
        io.write("   Compleated crafting ")
        gpu.setForeground(0x00FF00) -- Green
        io.write(entry.Name, "\n")
        gpu.setForeground(0xFFFFFF) -- White

    end



end
------------------------

----Function to pull items from dummy----
function GetStoredItems()
    local AppliedData = dummySystem.getItemsInNetwork() --Downloading data from Dummy Applied System
    local currList = {} --Placeholder table for items to return
    local NumberOfItems = AppliedData["n"] --Creating a variable that stors the number of items in dummy network

    if NumberOfItems == 0 then error("No Items In Dummy") end --Checks if dummy network has items
    
    for i=1, NumberOfItems do
        table.insert(currList, AppliedData[i])
    end

    return currList
end
-----------------------------------------

------Function that Creates Queque Object------
function CreateQueque(list)
    local queque = {}

    for _, value in pairs(list) do 
        
        
        local AppliedData = mainSystem.getItemsInNetwork({ ---Pulls Desired Item from main Netowrk
            label = value.label,
			name = value.name,
			damage = value.damage
        })

        if (AppliedData["n"] == 1) and AppliedData[1]["isCraftable"] == true then --Checks f item is craftable
             
            local token = mainSystem.getCraftables({
                label = value.label,
                name = value.name,
                damage = value.damage
            })
           
            if token["n"] ~= 1 then print(token["n"]) error("An error has occured when pulling token") end --Error check
            
            
            if AppliedData[1]["size"] < value["size"] then              --Calculates amount to craft
				local maxCraftsize = value["size"] * craftingConstant
				local delta = value["size"] - AppliedData[1]["size"]
				if delta > maxCraftsize then delta = maxCraftsize end
				delta = math.ceil(delta)

                table.insert(queque,{                   --Inserts Item to queque
                    Name = AppliedData[1].label,
                    ID = AppliedData[1].name,
                    Token = token[1],
                    Delta = delta,
                    Amount = AppliedData[1].size
                })

            end

        elseif AppliedData["n"] == 0 then
            io.write('Item "', value["label"], '" not found in main network but exists in dummy"\n' )
        
        elseif (AppliedData["n"] == 1) and AppliedData[1]["isCraftable"] == false then
            io.write('Item "', AppliedData[1]["label"], '" has no crafting recipe\n' )
        
        else print(AppliedData["n"]) error("An error has occured when pulling items from main") end

    end
    if queque[1] ~= nil then
        return queque
    else
        return nil
    end
end
-----------------------------------------------

-----Function That returns first free Cpu or nil-----
function GetCpu()
    local cpuInNetwork = mainSystem.getCpus() --Gets CPUs from main network

    for key, value in pairs(cpuInNetwork) do 
        if key ~= 'n' then
            
            for _, cpuName in pairs(cpus) do
                
                if (value["name"] == cpuName) and (value["busy"] == false) then
                    return value["name"]
                end
            
            end

        else return nil end
                  
    end
end
-----------------------------------------------------

--------Runner--------
main()