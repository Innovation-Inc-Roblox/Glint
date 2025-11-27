--Replicates whether users can chat with each other, since it is server-side.
--!strict

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local CanChatReplication = {}
CanChatReplication._Players = Players
CanChatReplication._CanChatCache = {} :: {[Player]: {number}}
CanChatReplication.__index = CanChatReplication

export type CanChatReplication = typeof(CanChatReplication)



--[[
Returns if 2 players can chat with each other.
--]]
function CanChatReplication._CanChat(self: CanChatReplication, Player1: Player, Player2: Player): boolean
    return TextChatService:CanUsersChatAsync(Player1.UserId, Player2.UserId)
end

--[[
Updates the replicated values for all players.
--]]
function CanChatReplication._UpdateReplicatedValues(self: CanChatReplication): ()
    for Player, CanChatResults in self._CanChatCache do
        Player:SetAttribute("CanChatIds", table.concat(CanChatResults, ","))
    end
end

--[[
Initializes a list of players.
--]]
function CanChatReplication._InitializePlayers(self: CanChatReplication, PlayersToInitialize: {Player}): ()
    --Add the new players to the others entries.
    for _, Player in PlayersToInitialize do
        for OtherPlayer, CanChatResults in self._CanChatCache do
            if not self:_CanChat(Player, OtherPlayer) then continue end
            table.insert(CanChatResults, Player.UserId)
        end
    end

    --Initialize the cache entries for the players.
    for _, Player in PlayersToInitialize do
        local CanChatResults = {}
        for _, OtherPlayer in self._Players:GetPlayers() do
            if not self:_CanChat(Player, OtherPlayer) then continue end
            table.insert(CanChatResults, OtherPlayer.UserId)
        end
        self._CanChatCache[Player] = CanChatResults
    end

    --Update the replicated values.
    self:_UpdateReplicatedValues()
end

--[[
Uninitializes a player.
--]]
function CanChatReplication._UninitializePlayer(self: CanChatReplication, Player: Player): ()
    --Remove the player.
    self._CanChatCache[Player] = nil

    --Remove the player from the other entries.
    for OtherPlayer, CanChatResults in self._CanChatCache do
        for i = #CanChatResults, 1, -1 do
            if CanChatResults[i] ~= Player.UserId then continue end
            table.remove(CanChatResults, i)
        end
    end

    --Update the replicated values.
    self:_UpdateReplicatedValues()
end



if RunService:IsRunning() then
    --Connect players joining.
    Players.PlayerAdded:Connect(function(Player)
        CanChatReplication:_InitializePlayers({Player})
    end)
    CanChatReplication:_InitializePlayers(Players:GetPlayers())

    --Connect players leaving.
    Players.PlayerRemoving:Connect(function(Player)
        CanChatReplication:_UninitializePlayer(Player)
    end)
end



return CanChatReplication