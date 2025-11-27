--Displays icons above players.
--!strict

local Players = game:GetService("Players")

local IconFactory = require(script.Parent:WaitForChild("IconFactory"))

local PlayerIcons = {}
PlayerIcons._Players = Players
PlayerIcons._IconsContainer = Instance.new("Folder") :: Instance
PlayerIcons._PlayerEventConnections = {} :: {[Player]: {RBXScriptConnection}}
PlayerIcons._PlayerIcons = {} :: {[Player]: BillboardGui}
PlayerIcons._CanChatIds = {} :: {[number]: boolean}

export type PlayerIcons = typeof(PlayerIcons)



--[[
Returns the adornee for a player.
This can yield.
--]]
function PlayerIcons.GetAdornee(Player: Player): BasePart?
    if not Player.Character then return nil end
    return Player.Character:WaitForChild("Head", 10 ^ 99) :: BasePart
end

--[[
Returns an event for a player to update their icon's adornee.
--]]
function PlayerIcons.GetAdorneeUpdateEvent(Player: Player): RBXScriptSignal
    return Player.CharacterAdded
end

--[[
Updates the icon for a player.
--]]
function PlayerIcons._UpdateIcon(self: PlayerIcons, Player: Player): ()
    --Remove the icon if one exists and the player can chat.
    if self._CanChatIds[Player.UserId] then
        if self._PlayerIcons[Player] then
            self._PlayerIcons[Player]:Destroy()
            self._PlayerIcons[Player] = nil
        end
        return
    end

    --Update the icon if it exists, or create a new one.
    local Adornee = self.GetAdornee(Player)
    local ExistingIcon = self._PlayerIcons[Player]
    if ExistingIcon then
        ExistingIcon.Adornee = Adornee
    elseif Adornee then
        local NewIcon = IconFactory.CreateIcon(Player)
        NewIcon.Adornee = Adornee
        NewIcon.Parent = self._IconsContainer
        self._PlayerIcons[Player] = NewIcon
    end
end

--[[
Updates the can chat ids.
--]]
function PlayerIcons._UpdateCanChatIds(self: PlayerIcons, CanChatIds: string?): ()
    --Update the ids.
    self._CanChatIds = {}
    if CanChatIds then
        for _, Id in string.split(CanChatIds, ",") do
            local IdNumber = tonumber(Id)
            if not IdNumber then continue end
            self._CanChatIds[IdNumber] = true
        end
    end

    --Update the players.
    for _, Player in self._Players:GetPlayers() do
        self:_UpdateIcon(Player)
    end
end

--[[
Initializes a player.
--]]
function PlayerIcons._InitializePlayer(self: PlayerIcons, Player: Player): ()
    --Connect the icon adornee changing.
    local PlayerEventConnections = {}
    table.insert(PlayerEventConnections, self.GetAdorneeUpdateEvent(Player):Connect(function()
        self:_UpdateIcon(Player)
    end))
    self._PlayerEventConnections[Player] = PlayerEventConnections

    --Update the initial icon.
    self:_UpdateIcon(Player)
end

--[[
Uninitializes a player.
--]]
function PlayerIcons._UninitializePlayer(self: PlayerIcons, Player: Player): ()
    --Disconnect any events.
    if not self._PlayerEventConnections[Player] then return end
    for _, EventConnection in PlayerIcons._PlayerEventConnections[Player] do
        EventConnection:Disconnect()
    end
    PlayerIcons._PlayerEventConnections[Player] = nil

    --Remove any icons.
    if not self._PlayerIcons[Player] then return end
    self._PlayerIcons[Player]:Destroy()
    self._PlayerIcons[Player] = nil
end

--[[
Initializes player icons.
--]]
function PlayerIcons.Initialize(self: PlayerIcons): ()
    --Change the icon container.
    local LocalPlayer = self._Players.LocalPlayer :: Player
    PlayerIcons._IconsContainer = LocalPlayer:WaitForChild("PlayerGui")

    --Connect the players.
    self._Players.PlayerAdded:Connect(function(Player)
        PlayerIcons:_InitializePlayer(Player)
    end)
    for _, Player in self._Players:GetPlayers() do
        task.spawn(function()
            PlayerIcons:_InitializePlayer(Player)
        end)
    end

    --Connect tha players leaving.
    self._Players.PlayerRemoving:Connect(function(Player)
        PlayerIcons:_UninitializePlayer(Player)
    end)

    --Connect changes to the can chat players.
    LocalPlayer:GetAttributeChangedSignal("CanChatIds"):Connect(function()
        PlayerIcons:_UpdateCanChatIds(LocalPlayer:GetAttribute("CanChatIds") :: string?)
    end)
    PlayerIcons:_UpdateCanChatIds(LocalPlayer:GetAttribute("CanChatIds") :: string?)
end



return PlayerIcons