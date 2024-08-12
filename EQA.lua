-- event: GOSSIP_SHOW
-- GetGossipAvailableQuests() returns title1, level1, isLowLevel1, isDaily1, isRepeatable1 [, title2, level2, isLowLevel2, , isDaily2, isRepeatable2...]
-- GetNumGossipAvailableQuests() returns number


--[[
TODO:

!Add the rest of the base stat weights

]]




--QUEST_COMPLETE fired

--GameTooltip:AddDoubleLine()

local e = aura_env
local c = e.config
local f = WeakAuras.regions[e.id].region

e.availableQuests = {}
e.activeQuests = {}
e.ImportantItem = false
e.texturepool = {}
e.Class = select(2,UnitClass("player"))
e.lastTurnIn = 0
e.ActiveProfile = 0

e.checkTooltips = {}

e.exceptionClasses = {
    ["WARRIOR"] = true,
    ["PALADIN"] = true,
    ["SHAMAN"] = true,
    ["HUNTER"] = true,
}

function e.sendMessage(msg)
    if msg then
        print("|cff48C9B0Empress Quest Assist: |r"..msg)
    end
end

function e.log(...)
    if not c.debugKey then return end
    --[[local groupName,prefix,message = ...
    WeakAuras.ScanEvents("DPRINT", groupName, prefix, message, select(4, ...))
    local textTable = {}
    textTable = ...
    local header = select(1,...)
    local returnText = ""
    local counter = 1
    print("|cff42b7ff EQA Debug: "..header)
    for text in pairs(textTable) do
        returnText = "[|cff03fcc6"..counter.."|]: "..(text or "")
        print(returnText)
        counter = counter + 1
    end
end

function e.logTable(table)
    if msg and c.debugKey then
        for i,v in pairs(table) do
            print("|cff42b7ff["..i.."]|r: "..v)
        end
    end
end]]
end

e.alwaysShowProfiles = {}
if c.autoName then
    for i,v in pairs(c.statWeights) do
        --print("statweight: "..c.statWeights[i].name.. "     ".. "Class: ".. e.Class)
        if c.statWeights[i].name == UnitName("player") then
            e.ActiveProfile = i
            if e.ActiveProfile == i then
                e.sendMessage("Active Name profile is - "..c.statWeights[i].name)
            end
        end
    end
end

if c.autoClass and e.ActiveProfile == 0 then
    for i,v in pairs(c.statWeights) do
        --print("statweight: "..c.statWeights[i].name.. "     ".. "Class: ".. e.Class)
        if c.statWeights[i].name == e.Class then
            e.ActiveProfile = i
            if e.ActiveProfile == i then
                e.sendMessage("Active CLASS profile is - "..c.statWeights[i].name)
            end
        end
    end
end

for i,v in pairs(c.statWeights) do
    if e.ActiveProfile == 0 and c.activeProfile == c.statWeights[i].name then
        e.ActiveProfile = i
    end
    if c.statWeights[i].showTooltip and not (c.activeProfile == c.statWeights[i].name) then
        e.alwaysShowProfiles[#e.alwaysShowProfiles+1] = i
    end
end




function e.noProfile()
    e.sendMessage("Profile not selected, fix in Custom Options!")
end

if e.ActiveProfile == 0 then
    e.noProfile()
end

function e.ShowValue(tooltip)
    if not tooltip then return end
    local _,item = tooltip:GetItem()
    tooltip.IsUpgrade = false
    tooltip:SetBackdropBorderColor(0.13,0.13,0.13)
    _G[tooltip:GetName().."TextRight1"]:SetText(nil)
    if item then
        local iteminfo = GetItemStats(item)
        local loc = select(9,GetItemInfo(item))
        local slot = e.equipLoctoSlot[loc]
        --print(loc)
        local equippedValue = e.GetCurrentItemValue(loc)
        local value = e.GetValueForItem(iteminfo, item, false, nil, slot)
        --print(equippedValue)
        local returncolor = ""
        local returnpercent = ""
        if value and value > 0 then
            tooltip:AddDoubleLine(Left)
            if equippedValue and tooltip == GameTooltip then
                if (value/equippedValue) > 1 then
                    returncolor = "|cff00ff00"
                    returnpercent = "  +"..math.floor(1000*(value/equippedValue))/10-100 .."%"
                    if e.canUseItem(select(6, GetItemInfo(item))) then
                        tooltip.IsUpgrade = true
                        tooltip:SetBackdropBorderColor(0,1,0)
                        _G[tooltip:GetName().."TextRight1"]:SetText("|cff00ff00UPGRADE!|r")
                    end
                elseif (value/equippedValue) < 1 then
                    returncolor = "|cffff0000"
                    returnpercent = "  "..math.floor(1000*(value/equippedValue))/10-100 .."%"
                end
            end
            tooltip:AddLine(c.statWeights[e.ActiveProfile].name..": "..math.floor(100*value)/100 ..returncolor..returnpercent, 0.282,0.788,0.69)
        end
        if e.alwaysShowProfiles then
            for i=1,#e.alwaysShowProfiles do
                value = e.GetValueForItem(iteminfo, item, false, e.alwaysShowProfiles[i], slot)
                equippedValue = e.GetCurrentItemValue(loc, false, e.alwaysShowProfiles[i])
                --print(equippedValue)
                if value and value > 0 then
                    tooltip:AddDoubleLine(Left)
                    --tooltip:AddLine(" ")
                    returncolor = ""
                    returnpercent = ""
                    if equippedValue and tooltip == GameTooltip then
                        if (value/equippedValue) > 1 then
                            returncolor = "|cff00ff00"
                            returnpercent = "  +"..math.floor(1000*(value/equippedValue))/10-100 .."%"
                            if e.canUseItem(select(6, GetItemInfo(item))) then
                                tooltip.IsUpgrade = true
                                tooltip:SetBackdropBorderColor(0,1,0)
                                _G[tooltip:GetName().."TextRight1"]:SetText("|cff00ff00UPGRADE!|r")
                            end
                        elseif (value/equippedValue) < 1 then
                            returncolor = "|cffff0000"
                            returnpercent = "  "..math.floor(1000*(value/equippedValue))/10-100 .."%"
                        end
                    end
                    tooltip:AddLine(c.statWeights[e.alwaysShowProfiles[i]].name..": "..math.floor(100*value)/100 ..returncolor..returnpercent, 0.282,0.788,0.69)
                end
            end
        end
    end
end

function e.unColor(tooltip)
    if not tooltip:GetItem() then
        tooltip:SetBackdropBorderColor(0.13,0.13,0.13)
    end
end

if not WA_HaveSetItemScripts then
    GameTooltip:HookScript("OnTooltipSetItem", e.ShowValue)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", e.ShowValue)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", e.ShowValue)
    if AtlasLootTooltip then
        AtlasLootTooltip:HookScript("OnTooltipSetItem", e.ShowValue)
    end
    if AuxTooltip then
        AuxTooltip:HookScript("OnTooltipSetItem", e.ShowValue)
    end
    GameTooltip:HookScript("OnUpdate", e.unColor)

    WA_HaveSetItemScripts = true
end

-- *Check if Bag items are upgrades and give the frame the information

function e.GetBagUpgrades()
    WA_BagUpgrades = {}
    if AdiBagsItemButton1 then
        for i = 1,360 do
            local frame = _G["AdiBagsItemButton"..i]
            if frame and frame.itemLink then
                local itemLink = frame.itemLink
                --print(itemLink)
                local iteminfo = GetItemStats(itemLink)
                local loc = select(9,GetItemInfo(itemLink))
                local slot = e.equipLoctoSlot[loc]
                --print(loc)
                local equippedValue = e.GetCurrentItemValue(loc)
                local value = e.GetValueForItem(iteminfo, itemLink, false, nil, slot)
                --print(equippedValue, value, "=", value - equippedValue)
                if value and value > 0 then
                    if equippedValue then
                        if e.canUseItem(select(6, GetItemInfo(itemLink))) then
                            if (value/equippedValue) > 1 then
                                --print(itemLink)
                                --print(i, frame, "is upgrade", value - equippedValue)
                                table.insert(WA_BagUpgrades, {["frame"] = i, ["AdiBags"] = true})

                                if frame then
                                    frame.isUpgrade = true
                                end
                            elseif value == equippedValue then
                            elseif (value/equippedValue) < 1 then
                                if frame then
                                    frame.isDowngrade = true
                                end
                            end
                        end
                    elseif e.canUseItem(select(6, GetItemInfo(itemLink))) then
                        if frame then
                            frame.isUpgrade = true
                        end
                    end
                end
            end
        end
        WeakAuras.ScanEvents("BAG_UPGRADE")
        return
    end
    for bag=0,NUM_BAG_SLOTS do
        for slotID=1,GetContainerNumSlots(bag) do
            local frame = _G["ElvUI_ContainerFrameBag".. bag .."Slot".. slotID]
            if frame then frame.isUpgrade = false end
            if GetContainerItemID(bag,slotID) then

                local itemLink = select(7,GetContainerItemInfo(bag,slotID))
                --print(bag, slotID, itemLink)
                if ArkInventory then
                    local frame = _G["ARKINV_Frame1ContainerBag".. bag+1 .."Item"..slotID]
                end

                if itemLink then

                    local iteminfo = GetItemStats(itemLink)
                    local loc = select(9,GetItemInfo(itemLink))
                    local slot = e.equipLoctoSlot[loc]
                    --print(loc)
                    local equippedValue = e.GetCurrentItemValue(loc)
                    local value = e.GetValueForItem(iteminfo, itemLink, false, nil, slot)
                    --print(equippedValue, value, "=", value - equippedValue)
                    if value and value > 0 then
                        if equippedValue then
                            if e.canUseItem(select(6, GetItemInfo(itemLink))) then
                                if (value/equippedValue) > 1 then
                                    table.insert(WA_BagUpgrades, {["bag"] = bag, ["slot"] = slotID, ["delta"] = (value or 0) - (equippedValue or 0), ["hasFrame"] = false})

                                    if frame then
                                        frame.isUpgrade = true
                                    end
                                elseif value == equippedValue then
                                elseif (value/equippedValue) < 1 then
                                    if frame then
                                        frame.isDowngrade = true
                                    end
                                end
                            end
                        elseif e.canUseItem(select(6, GetItemInfo(itemLink))) then
                            if frame then
                                frame.isUpgrade = true
                            end
                        end
                    end
                end

            end
        end
    end
    WeakAuras.ScanEvents("BAG_UPGRADE")
end
-- *Check if Roll Item is upgrade
function e.rollitemUpgrade(item)
    --local item = GetLootRollItemLink(rollID)
    if item then
        local iteminfo = GetItemStats(item)
        local loc = select(9,GetItemInfo(item))
        local slot = e.equipLoctoSlot[loc]
        local equippedValue = e.GetCurrentItemValue(loc)
        --print(equippedValue)
        local value = e.GetValueForItem(iteminfo, item, false, nil, slot)
        --print(value)
        if value and value > 0 and e.canUseItem(select(6, GetItemInfo(item))) then
            if equippedValue and (value/equippedValue) > 1 then
                --print(rollID, "Is an upgrade")
                return true
            end
        end
    end
end

function e.ColorLootRollIfUpgrade()
    if not ElvUI then return end
    for i = 1,4 do
        local cur = _G["ElvUI_GroupLootFrame"..i]
        if cur and e.rollitemUpgrade(cur.itemButton.link) and cur:IsShown() then
            cur:SetBackdropBorderColor(0,1,0)
            if e.texturepool and e.texturepool["LRUpgradeArrow"..i] then
                e.texturepool["LRUpgradeArrow"..i]:ClearAllPoints()
                e.texturepool["LRUpgradeArrow"..i]:SetVertexColor(0,1,0,1)
                e.texturepool["LRUpgradeArrow"..i]:SetPoint("LEFT", "ElvUI_GroupLootFrame"..i, "LEFT", -36, 0)
                e.texturepool["LRUpgradeArrow"..i]:Show()
            end
        elseif cur and cur:IsShown() then
            cur:SetBackdropBorderColor(0,0,0)
            if e.texturepool and e.texturepool["LRUpgradeArrow"..i] then
                e.texturepool["LRUpgradeArrow"..i]:SetVertexColor(0,1,0,0)
                e.texturepool["LRUpgradeArrow"..i]:Hide()
            end
        else
            if e.texturepool and e.texturepool["LRUpgradeArrow"..i] then
                e.texturepool["LRUpgradeArrow"..i]:SetVertexColor(0,1,0,0)
                e.texturepool["LRUpgradeArrow"..i]:Hide()
            end
        end
    end
end

e.equipLoctoSlot = {
    ["INVTYPE_AMMO"] = 0,
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] =     4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] =     5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = 11,--{11,12},
    ["INVTYPE_TRINKET"] = 13,--{13,14},
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_WEAPON"] = 16,--{16,17},
    ["INVTYPE_SHIELD"] = 17,
    ["INVTYPE_2HWEAPON"] = 16,
    ["INVTYPE_WEAPONMAINHAND"] = 16,
    ["INVTYPE_WEAPONOFFHAND"] = 17,
    ["INVTYPE_HOLDABLE"] = 17,
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_THROWN"] = 18,
    ["INVTYPE_RANGEDRIGHT"] = 18,
    ["INVTYPE_RELIC"] = 18,
    ["INVTYPE_TABARD"] = 19,
    ["INVTYPE_BAG"] = 20,--{20,21,22,23},
}

e.CanAlwaysUse = {
    ["INVTYPE_NECK"] = true,
    ["INVTYPE_CLOAK"] = true,
    ["INVTYPE_FINGER"] = true,
    ["INVTYPE_TRINKET"] = true,
    ["INVTYPE_TABARD"] = true,
    ["INVTYPE_BAG"] = true,
}

e.SlotTranslate = {
    ["One-Handed Maces"] = "Maces",
    ["One-Handed Swords"] = "Swords",
    ["One-Handed Axes"] = "Axes",
    ["One-Handed Dagger"] = "Daggers",
    ["Shields"] = "Shield",
}

e.dump = function(dump)
    AceLibrary('AceConsole-2.0'):PrintLiteral(dump)
end

-- Create Tooltip for Hooking item text (Used for speed determination)
function e.createTooltip()
    CreateFrame( "GameTooltip", "EQATooltip", nil, "GameTooltipTemplate" ) -- Tooltip name cannot be nil
    EQATooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
    -- Allow tooltip SetX() methods to dynamically add new lines based on these
    EQATooltip:AddFontStrings(
            EQATooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
            EQATooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" )
    )
end
e.createTooltip()

--Bag Space Check
function e.getEmptyBagSlots()
    local Bags = {}
    local slots,type
    local EmptySlots = 0
    --Check Number of Bags
    for i=1,4 do
        if not GetInventoryItemCount("unit", 19+i) then
            Bags[i] = true
        else
            Bags[i] = false
        end
    end

    for i=1,5 do
        slots, type = GetContainerNumFreeSlots(i-1);
        if type == 0 then
            EmptySlots = EmptySlots+slots
        end
    end
    --print(EmptySlots)
    return EmptySlots
end

function e.SellStuff()
    if c.autoSell then
        --print("EQA - Automatically Selling Items")
        for bag=0,4,1 do

            for slot=1,GetContainerNumSlots(bag),1 do
                local name=GetContainerItemLink(bag,slot)
                if name and string.find(name,"ff9d9d9d") then
                    UseContainerItem(bag,slot)
                end
            end
        end
        for bag=0,4,1 do
            for slot=1,GetContainerNumSlots(bag),1 do
                local item=GetContainerItemLink(bag,slot)
                if item and (c.autoSellWhite and (string.find(item,"ffffffff")) or (c.autoSellGreen and string.find(item,"ff1eff00"))) then
                    local loc = select(9,GetItemInfo(item))
                    local eslot = e.equipLoctoSlot[loc]
                    --print(item, loc, slot)
                    if eslot and eslot ~= 20 and eslot ~= 19 and eslot ~= 16 then
                        --print(item, "passed slot")
                        local iteminfo = GetItemStats(item)
                        local equippedValue = e.GetCurrentItemValue(loc)
                        --print(equippedValue)
                        local value = e.GetValueForItem(iteminfo, item, false, nil, eslot)
                        --print(value)
                        if value and value > 0 and e.canUseItem(select(6, GetItemInfo(item))) then
                            if equippedValue and equippedValue ~= 0 and (value/equippedValue) > 1 then

                            else
                                UseContainerItem(bag,slot)
                            end
                        else
                            UseContainerItem(bag,slot)
                        end
                    end
                end
            end
        end
    end
end
--Available
--Quests
--Portion

function e.pickAvailableQuest(index, isQuestGreeting)
    if isQuestGreeting then
        SelectAvailableQuest(index)
    else
        SelectGossipAvailableQuest(index)
    end
end

function e.blockQuest(index, complete) --Introduce Checks here if you want to pick the quest or not.
    return false
end

-- *Texture Creation

function e.createTexture(name, strata, texture, sizex, sizey, r, g, b, o)
    if not e.texturepool[name] then
        local newTexture = CreateFrame("Frame")
        newTexture:SetFrameStrata(strata)
        e.texturepool[name] = newTexture
        e.texturepool[name] = e.texturepool[name]:CreateTexture(nil, strata)
        e.texturepool[name]:SetTexture(texture)
    end
    e.texturepool[name]:ClearAllPoints()
    e.texturepool[name]:SetVertexColor(r or 1, g or 1, b or 1, o or 1)
    e.texturepool[name]:SetSize(sizex or 30, sizey or 30)
    e.texturepool[name]:Hide()
end

function e.hideTexture(texture)
    if e.texturepool and e.texturepool[texture] then
        e.texturepool[texture]:Hide()
    end
end


e.createTexture("Checkmark", "HIGH", "Interface\\AddOns\\WeakAuras\\Media\\Textures\\ok-icon.tga", 30, 30)
e.createTexture("Goldmark", "HIGH", "interface\\buttons\\ui-grouploot-coin-up.blp", 12, 12)
--create lootframe upgrade icons
for i=1,4,1 do
    e.createTexture("LRUpgradeArrow"..i,"FULLSCREEN", "Interface\\AddOns\\WeakAuras\\Media\\Textures\\targeting-mark.tga", 36, 36, 0, 1, 0, 1)
    if e.texturepool and e.texturepool["LRUpgradeArrow"..i] then
        e.texturepool["LRUpgradeArrow"..i]:SetTexCoord(0, 1, 1, 0)
    end
end

function e.showTexture(texture, itemIndex, x, y, xo, yo, fallbackTexture)
    if not e.texturepool[texture] then
        e.createTexture(texture, "HIGH", fallbackTexture, x, y)
    end
    e.texturepool[texture]:ClearAllPoints()
    if itemIndex and _G["QuestInfoItem"..itemIndex] then
        e.texturepool[texture]:SetPoint("LEFT", "QuestInfoItem"..itemIndex, "LEFT", xo, yo)
    end
    e.texturepool[texture]:Show()
end

--
--Completed Quests Portion
--

function e.HasBagSpace()
    local forcedItem = GetNumQuestRewards()
    local numChoices = GetNumQuestChoices()
    if forcedItem == 0 and numChoices == 0 then
        return true, true
    end
    local space = e.getEmptyBagSlots()
    if numChoices ~= 0 then
        if space >= forcedItem + 1 then
            return true, false
        end
    else
        if space >= forcedItem then
            return true, true
        end
    end
    WeakAuras.ScanEvents("FULL_INVENTORY")
    return false, false
end

function e.canUseItem(type, subtype, _, invtype)
    if e.CanAlwaysUse[invtype] then
        return true
    end

    if subtype == "Food & Drink" then
        return true
    end
    --print("Found Type is: ", type, subtype)
    for i = 1, GetNumSkillLines() do
        local name = GetSkillLineInfo(i)
        if type == "Armor" then
            if e.SlotTranslate[subtype] then
                if name == e.SlotTranslate[subtype] then
                    --print("Translation sucessful: ", e.WeaponSlotTranslate[subtype])
                    return true
                end
            else
                if name == subtype then
                    --print("No Translation needed: ", subtype, " found")
                    return true
                end
            end
            if c.armorException and e.exceptionClasses[e.Class] and (UnitLevel("player") or 0) > 30 then
                if subtype == "Plate" and (e.Class == "WARRIOR" or e.Class == "PALADIN") then
                    return true
                elseif subtype == "Mail" then
                    return true
                end
            end
        elseif type == "Weapon" then
            --print("looking to see if I can use a: Weapon")
            if e.SlotTranslate[subtype] then
                if name == e.SlotTranslate[subtype] then
                    --print("Translation sucessful: "..e.WeaponSlotTranslate[subtype])
                    return true
                end
            else
                if name == subtype then
                    return true
                end
            end
        end
    end
    return false
end

function e.splitString(string, delimiter)
    local result = {};
    for match in (string..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function e.GetWeaponSpeed(slot,item)
    if item then
        EQATooltip:ClearLines()
        EQATooltip:SetHyperlink(item)
        for line = 3,6,1 do --Check the common lines
            local currentline=_G["EQATooltipTextRight"..line]

            if currentline then
                local text=currentline:GetText()
                if text then
                    local splits = e.splitString(text, " ")
                    if splits[1] == "Speed" then
                        if splits[2] then
                            return tonumber(splits[2])
                        end
                    end
                end
            end
        end
    end
end

function e.GetSetBonus(slot,item)
    if item then
        EQATooltip:ClearLines()
        EQATooltip:SetHyperlink(item)
        for line = 3,6,1 do --Check the common lines
            local currentline=_G["EQATooltipTextRight"..line]

            if currentline then
                local text=currentline:GetText()
                if text then
                    local splits = e.splitString(text, " ")
                    if splits[1] == "Speed" then
                        if splits[2] then
                            return tonumber(splits[2])
                        end
                    end
                end
            end
        end
    end
end


function e.GetValueForItem(table, item, quest, profile, slot, tooltip)
    --print(table, quest, profile, slot, tooltip, equipped)
    if not item then return 0 end
    local stats = table
    if not stats then return end
    local totals = 0
    local loc = select(9,GetItemInfo(item))
    --print("Trying to get Value from Item")
    if e.ActiveProfile == 0 and quest then
        e.noProfile()
        return
    end
    if not profile then
        profile = e.ActiveProfile
    end
    if not c.statWeights[profile] then
        e.sendMessage("No Profile detected, fix this in config.")
        return
    end
    for i,v in pairs(c.statWeights[profile]) do
        if stats[i] and stats[i] ~= 0 then
            totals = totals + stats[i]*v
        end
    end
    if slot == 16 then
        local speed = e.GetWeaponSpeed(16, item)
        --print(speed, c.statWeights[profile]["ITEM_MOD_SPEED_MELEE"], c.statWeights[profile]["ITEM_MOD_SPEED_MELEE"]*speed)
        if c.statWeights[profile]["ITEM_MOD_SPEED_MELEE"] and c.statWeights[profile]["ITEM_MOD_SPEED_MELEE"] ~= 0 and speed then
            totals = totals + c.statWeights[profile]["ITEM_MOD_SPEED_MELEE"]*speed
        end
    elseif slot == 18 then
        local speed = e.GetWeaponSpeed(18, item)
        --print(speed, c.statWeights[profile]["ITEM_MOD_SPEED_RANGED"], c.statWeights[profile]["ITEM_MOD_SPEED_RANGED"]*speed)
        if c.statWeights[profile]["ITEM_MOD_SPEED_RANGED"] and c.statWeights[profile]["ITEM_MOD_SPEED_RANGED"] ~= 0 and speed then
            totals = totals + c.statWeights[profile]["ITEM_MOD_SPEED_RANGED"]*speed
        end
    end
    if slot == 17 and c.statWeights[profile].ignoreOffHand then
        totals = 0
    end
    if loc == "INVTYPE_2HWEAPON" and c.statWeights[profile].ignoreTwoHand then
        totals = 0
    end
    --print(totals)
    return totals
end





function e.GetCurrentItemValue(itemslot, quest, profile)
    --print("Looking Up Current Item:")
    local slot = e.equipLoctoSlot[itemslot]
    if e.ActiveProfile == 0 and quest then
        e.noProfile()
        return
    end
    if not profile then
        profile = e.ActiveProfile
    end
    --print(slot)
    if c.stopItemSlot[tostring(slot)] and quest then
        e.sendMessage("Ignored Slot |cffee0909"..slot.."|r detected. Not turning in.")
        e.ImportantItem = true
    end
    if GetInventoryItemID("player", slot) then
        if not slot then return 0 end
        local item = GetInventoryItemLink("player", slot)
        local stats = GetItemStats(item)
        local value = e.GetValueForItem(stats, item, quest, profile, slot)

        return value
    else
        return 0
    end
end

function e.GetBestItem()
    local numChoices = GetNumQuestChoices()
    local choices, stats, value, type, subtype, equipLoc, delta, gold = {}, {}, {}, {}, {}, {}, {}, {}
    local goldIndex, goldValue = 0,0
    local item = {}
    local counter = 1
    e.ImportantItem = false
    local _
    local delta = {}
    for i=1,numChoices do
        choices[i] = GetQuestItemLink("choice", i)
        stats[i] = GetItemStats(choices[i])
        gold[i] = select(11, GetItemInfo(choices[i]))
        --e.dump(stats[i])
        type[i], subtype[i], _, equipLoc[i] = select(6, GetItemInfo(choices[i]))
        --print(type[i])
        --print(subtype[i])
        if (gold[i] > goldValue) or (gold[i] == goldValue) then
            goldIndex = i
            goldValue = gold[i]
        end
        --print(type[i], subtype[i])
        if e.canUseItem(type[i], subtype[i], _, equipLoc[i]) then --and (not c.goldOnly) then
            --print("can use "..i..", it is worth: "..e.GetValueForItem(stats[i]), choices[i]) --.RESTISTANCE0_NAME
            delta[i] = e.GetValueForItem(stats[i], choices[i])-(e.GetCurrentItemValue(equipLoc[i],true) or 0)
            if not item.delta then
                item = {["delta"] = delta[i], ["questRewardSlot"] = i}
            end
            if (delta[i] > item.delta) or (delta[i] == item.delta) then
                item = {["delta"] = delta[i], ["questRewardSlot"] = i}
            end
            --print("Delta for item "..i.." is: "..delta[i]) --(e.GetFullValueForItem(stats[i])-e.LookUpCurrentItem(equipLoc[i])))
        end
    end
    return item, goldIndex
end

function e.selectReward()
    local space, noreward = e.HasBagSpace()
    local item, goldIndex = e.GetBestItem()
    if ((item.delta or 1) <= 0) then --

    end
    --Set a marker for the most valuable item
    e.showTexture("Goldmark", goldIndex, 25, 25, -2, 7, "interface\\buttons\\ui-grouploot-coin-up.blp")

    if (item.delta or -1) > 0 then
        e.showTexture("Checkmark", item.questRewardSlot, 50, 50, -3, 0, "Interface\\AddOns\\WeakAuras\\Media\\Textures\\ok-icon.tga")
    end

    if e.ImportantItem or (not c.AutoReward) and (not e.ShiftDown) or not space or (not c.questEnabled) then
        return
    end

    if c.goldOnly or (((item.delta or 1) <= 0) and (not e.ImportantItem)) and (not e.ShiftDown) and c.questEnabled then
        GetQuestReward(goldIndex)
        return
    end

    if (item and item.questRewardSlot) and (not e.ImportantItem) and (not e.ShiftDown) and c.questEnabled  then
        GetQuestReward(item.questRewardSlot)
    end
end

-- *Quest Turn in and Accept Stuff

function e.completeActiveQuest()
    local space, noreward = e.HasBagSpace() --Get the status of the Bag
    if noreward and (not e.ShiftDown) and c.questEnabled then
        GetQuestReward()
        return
    end
    e.selectReward()
end


function e.GetActiveQuests(isQuestGreeting)
    local activeQuests = {}
    local active

    if isQuestGreeting then
        active = GetNumActiveQuests()
        SelectActiveQuest(1)
    else
        active = GetNumGossipActiveQuests()
    end
    if not active or active == 0 then return end --If no available quest, exit

    local name, level, isLowLevel, isComplete

    local count = 0
    for i = 1, active do
        if isQuestGreeting then
            --[[print("isQuestGreeting")
            name = GetActiveTitle(i)
            print(name)
            for index = 1, GetNumQuestLogEntries() do
                print("kek",GetQuestLogTitle(index))
                if GetQuestLogTitle(index) and GetQuestLogTitle(index) == name then
                    name, level, _,_,_,isComplete = GetQuestLogTitle(index)
                    e.logTable(GetQuestLogTitle(index))
                end
            end]]

        else
            name, level, isLowLevel, isComplete = select((i*4-3),GetGossipActiveQuests())
        end

        e.activeQuests[i] = {
            name = name,
            level = level,
            isLowLevel = isLowLevel,
            isComplete = isComplete,
        }
        --print(e.activeQuests[i].name)
    end
    return e.activeQuests
end

function e.turninActiveQuests(isQuestGreeting)
    local activeQuests
    if isQuestGreeting then
        activeQuests = e.GetActiveQuests(true)
    else
        activeQuests = e.GetActiveQuests(false)
    end
    if activeQuests  and c.questEnabled then
        e.log("|cff42b7ff EQA:".."Active Quests - ".. #activeQuests)
        --print("Passed activeQuests test", #activeQuests)
        for i = 1, #activeQuests do
            e.log(i)
            e.log("Looping", i)
            --print(activeQuests[i].isComplete)
            if activeQuests[i].isComplete then
                --print("Should Pick")
                if not e.blockQuest(i, true) then --blockQuest is a feature which puts a system into place to create exceptions
                    --print("Picking:",i)
                    if c.sunwellFix then
                        --print(e.lastTurnIn)
                        --print(isQuestGreeting, (e.lastTurnIn < GetTime()-0.1))
                        --print(e.lastTurnIn < GetTime()-0.1)
                        if isQuestGreeting and (e.lastTurnIn < GetTime()-0.1) then
                            SelectActiveQuest(i)
                        elseif  e.lastTurnIn < GetTime()-0.1 then
                            e.lastTurnIn = GetTime()
                            SelectGossipActiveQuest(i)
                        else
                            CloseGossip()
                            CloseMerchant()
                            CloseQuest()
                        end
                    else
                        if isQuestGreeting then
                            SelectActiveQuest(i)
                        else
                            SelectGossipActiveQuest(i)
                        end
                    end
                end
            end
        end
    end
end

function e.getAvailableQuests(isQuestGreeting)
    e.availableQuests = {}
    local available
    if isQuestGreeting then
        available = GetNumAvailableQuests()
    else
        available = GetNumGossipAvailableQuests()
    end

    if not available or available == 0 then return false end -- Exit if no Quests available

    local name, level, isLowLevel, isDaily, isRepeatable
    local count = 0

    for i = 1, available do
        if isQuestGreeting then
            name, level, isLowLevel, isDaily, isRepeatable = GetAvailableTitle(index), GetAvailableLevel(index), GetAvailableQuestInfo(i)
        else
            name, level, isLowLevel, isDaily, isRepeatable = select((i*5-4),GetGossipAvailableQuests())
        end
        e.availableQuests[i] = {
            name = name,
            level = level,
            isLowLevel = isLowLevel,
            isDaily = isDaily,
            isRepeatable = isRepeatable,
        }
    end

    for i = 1, #e.availableQuests do
        if not e.blockQuest(i, false) and (not e.ShiftDown)  and c.questEnabled then
            if isQuestGreeting then
                e.pickAvailableQuest(i, true)
            else
                e.pickAvailableQuest(i, false)
            end
        end
    end
    return true -- Check to see if you should start turning quests in
end

function e.QuestGreeting()
    if not GetNumAvailableQuests() or GetNumAvailableQuests() == 0 and not e.ShiftDown  and c.questEnabled then
        e.log("No Available Quests from QUEST_GREETING")
        e.turninActiveQuests(true)
    end
    e.getAvailableQuests(true)
end

-- *Initionation

function e:OnEvent(event, ...)
    --START_LOOT_ROLL arg1 = id
    if event == "BAG_UPDATE" or event == "UPDATE_BAG" or event == "BANKFRAME_OPENED" then
        e.GetBagUpgrades()
    end

    if event == "MERCHANT_SHOW" then
        e.SellStuff()
    end

    if event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" or event == "CANCEL_LOOT_ROLL" then
        if e.texturepool then
            for i = 1,4 do
                local frame = _G["ElvUI_GroupLootFrame"..i]
                if frame and not frame:IsShown() then
                    if e.texturepool["LRUpgradeArrow"..i] then
                        --e.texturepool["LRUpgradeArrow"..i]:ClearAllPoints()
                        e.texturepool["LRUpgradeArrow"..i]:SetVertexColor(0,1,0,0)
                        e.texturepool["LRUpgradeArrow"..i]:Hide()
                    end
                end
            end
        end
    end
    if event == "START_LOOT_ROLL" then
        e.ColorLootRollIfUpgrade()
    end
    --e.stop = false
    if event == "QUEST_FINISHED" then --Hide everything shown by the aura
        e.hideTexture("Checkmark")
        e.hideTexture("Goldmark")
    end

    if event == "UI_ERROR_MESSAGE" then --? This was to fix an edgecase, I don't remember what issue caused it.
        if arg1 == "The item was not found." or arg1 == "You can't carry any more of those items." then
            e.throttle = GetTime()
        end
    end

    --!Add this back in if it causes issues
    if e.throttle and (e.throttle+1 > GetTime()) then
        return false
    end
    --!End of add back in

    --Halt if shift is held, variable is set and triggered upon one of the quest events, so you can pause one step
    if IsLeftShiftKeyDown() then
        e.ShiftDown = true
    else
        e.ShiftDown = false
    end
    --Accept Quests
    e.getAvailableQuests()
    if event == "QUEST_DETAIL" and (not e.ShiftDown) then
        AcceptQuest()
    end

    --!Might change this
    if event == "FULL_INVENTORY" then
        e.name = "Full Inventory, empty to turn in quests."
        return true
    end
    if event == "QUEST_GREETING" then
        e.QuestGreeting()
    end
    --*Pertains to completing quests
    e.log("GetNumAvailQuests:", GetNumGossipAvailableQuests(), "GetNumGossip:", GetNumGossipAvailableQuests())
    if (event == "GOSSIP_SHOW") or (event == "QUEST_GREETING") then
        if not GetNumGossipAvailableQuests() or GetNumGossipAvailableQuests() == 0 and not e.ShiftDown then
            --print("Accept Quest: 1")
            e.turninActiveQuests()
        end
    end

    if event == "QUEST_COMPLETE" then
        e.completeActiveQuest()
    end
    if event == "QUEST_PROGRESS" and (not e.ShiftDown) then
        CompleteQuest()
    end
    if e.name == "Full Inventory, empty to turn in quests." then
        if e.getEmptyBagSlots() ~= 0 then
            e.name = ""
        end
    end

    return true

end

