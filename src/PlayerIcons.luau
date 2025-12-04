--Displays icons above players.
--!strict

local Players = game:GetService("Players")

local IconFactory = require(script.Parent:WaitForChild("IconFactory"))

local PlayerIcons = {}
PlayerIcons._Players = Players
PlayerIcons._IconsContainer = Instance.new("Folder") :: Instance
PlayerIcons._PlayerEventConnections = {} :: {[Player]: {RBXScriptConnection}}
PlayerIcons._PlayerIcons = {} :: {[Player]: BillboardGui}
PlayerIcons._PlayerIconAdorneeEvents = {} :: {[Player]: {Adornee: BasePart?, Connections: {RBXScriptConnection}}}
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
Removes the icon for a player.
--]]
function PlayerIcons._RemoveIcon(self: PlayerIcons, Player: Player): ()
    if self._PlayerIcons[Player] then
        self._PlayerIcons[Player]:Destroy()
        self._PlayerIcons[Player] = nil
    end
    if self._PlayerIconAdorneeEvents[Player] then
        for _, Connection in self._PlayerIconAdorneeEvents[Player].Connections do
            Connection:Disconnect()
        end
        self._PlayerIconAdorneeEvents[Player] = nil
    end
end

--[[
Updates the icon for a player.
--]]
function PlayerIcons._UpdateIcon(self: PlayerIcons, Player: Player): ()
    --Remove the icon if one exists and the player can chat.
    if self._CanChatIds[Player.UserId] then
        self:_RemoveIcon(Player)
        return
    end

    --Update the icon if it exists, or create a new one.
    --The icon is not shown if the adornee is hidden.
    --Adornee and IconAdornee are separate to ensure the adornee can have events connected later on.
    local Adornee = self.GetAdornee(Player)
    local IconAdornee = Adornee
    if Adornee and (Adornee.Transparency >= 1 or Adornee.LocalTransparencyModifier >= 1) then
        IconAdornee = nil
    end
    local ExistingIcon = self._PlayerIcons[Player]
    if ExistingIcon then
        ExistingIcon.Enabled = (IconAdornee ~= nil)
        ExistingIcon.Adornee = IconAdornee
    elseif IconAdornee then
        local NewIcon = IconFactory.CreateIcon(Player)
        NewIcon.Adornee = IconAdornee
        NewIcon.Parent = self._IconsContainer
        self._PlayerIcons[Player] = NewIcon
    end

    --Connect updates to the transparency if the adornee changed.
    local CurrentPlayerIconAdorneeEvents = self._PlayerIconAdorneeEvents[Player]
    if not CurrentPlayerIconAdorneeEvents or CurrentPlayerIconAdorneeEvents.Adornee ~= Adornee then
        --Prepare storing event connections if this is the first setup.
        if not CurrentPlayerIconAdorneeEvents then
            CurrentPlayerIconAdorneeEvents = {Adornee = Adornee, Connections = {}}
            self._PlayerIconAdorneeEvents[Player] = CurrentPlayerIconAdorneeEvents
        end
        if not CurrentPlayerIconAdorneeEvents then return end --Only for type checking.

        --Disconnect existing events if the adornee changed.
        if CurrentPlayerIconAdorneeEvents.Adornee ~= Adornee then
            for _, EventConnection in CurrentPlayerIconAdorneeEvents.Connections do
                EventConnection:Disconnect()
            end
            table.clear(CurrentPlayerIconAdorneeEvents.Connections)
            CurrentPlayerIconAdorneeEvents.Adornee = Adornee
        end

        --Connect new events.
        if Adornee then
            table.insert(CurrentPlayerIconAdorneeEvents.Connections, Adornee:GetPropertyChangedSignal("Transparency"):Connect(function()
                self:_UpdateIcon(Player)
            end))
            table.insert(CurrentPlayerIconAdorneeEvents.Connections, Adornee:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
                self:_UpdateIcon(Player)
            end))
        end
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
    self:_RemoveIcon(Player)
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