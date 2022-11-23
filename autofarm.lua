-- // variables
local player = game:GetService("Players").LocalPlayer
local replicatedstorage = game:GetService("ReplicatedStorage")

local MLIB = require(replicatedstorage.MoneyLib)

-- // settings
local settings = {
    AdjustSpeed = 10; -- makes conveyors faster
    WaitTime = 3; -- i've found 3 effective
    LayoutToUse = 1; -- which layout you should use
}

-- // functions 
local function findplayerbase()
    local PlayersBase

    for i, base in pairs(workspace.Tycoons:GetChildren()) do
        if base.Owner.Value == player.Name then		
            PlayersBase = base; break;
        end
    end
    
    return PlayersBase
end

local base = assert(findplayerbase(), 'no base?')

local function canrebirth()

    local Money = replicatedstorage.MoneyMirror:FindFirstChild(player.Name)
    local currentMoney = Money.Value
    local nextprice = MLIB.RebornPrice(player)
    local skipamt = MLIB.LifeSkips(player, currentMoney)
    
    local c = math.log10(currentMoney)  / math.log10(nextprice);

    return c > 1 and true or false
end

local function ascend()
    if (not canrebirth) then
        return
    end

    replicatedstorage.Rebirth:InvokeServer(math.random(1, 26))
end

local function loadlayout(int)
    local choice = ("Layout%s"):format(int)

    replicatedstorage.Layouts:InvokeServer("Load", choice)
    
    return
end

local function checkifshouldloadsetup()
    return base:FindFirstChildOfClass('Model') ~= nil
end

local function OnChildRemoved(...)
    local canload = checkifshouldloadsetup()
    
    if (not canload) then
        return
    end

    task.spawn(function()
        task.wait(settings.WaitTime or 2.5)
        loadlayout(settings.LayoutToUse or 1)
    end)
end

-- // additional things
base.AdjustSpeed.Value = settings.AdjustSpeed

-- // connections
base.ChildRemoved:Connect(OnChildRemoved)
player.leaderstats.Cash:GetPropertyChangedSignal("Value"):Connect(ascend)

-- // init

replicatedstorage.DestroyAll:InvokeServer()
ascend()

task.spawn(function()
    task.wait(settings.WaitTime or 2.5)
    loadlayout(settings.LayoutToUse or 1)
end)