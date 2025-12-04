--Replicates whether users can chat with each other, since it is server-side.
--!strict

local REFRESH_CAN_CHAT_DELAY_SECONDS = 15
local REFRESH_CAN_CHAT_PLAYERS_PER_STEP = 5
local REFRESH_CAN_CHAT_STEP_DELAY_SECONDS = 1

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
    return Player1 == Player2 or TextChatService:CanUsersChatAsync(Player1.UserId, Player2.UserId)
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
Refreshes the players a player can chat with.
--]]
function CanChatReplication._RefreshPlayer(self: CanChatReplication, Player: Player): ()
    --Return if the player is not initialized.
    local CanChatResults = self._CanChatCache[Player]
    if not CanChatResults then return end
    
    --Update the can chat results.
    for OtherPlayer, OtherPlayerCanChatResults in self._CanChatCache do
        if Player == OtherPlayer then continue end
        if table.find(CanChatResults, OtherPlayer.UserId) then continue end
        if not self:_CanChat(Player, OtherPlayer) then continue end
        table.insert(CanChatResults, OtherPlayer.UserId)
        table.insert(OtherPlayerCanChatResults, Player.UserId)
    end
end

--[[
Refreshes the players a player can chat with for a list a players.
--]]
function CanChatReplication._RefreshPlayers(self: CanChatReplication, PlayersToUpdate: {Player}): ()
    for _, Player in PlayersToUpdate do
        self:_RefreshPlayer(Player)
    end
    self:_UpdateReplicatedValues()
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

    --Refresh can chat lists in the background.
    --Players are able to verify after joining, and the API seems to default to false on join and eventually return true.
    task.spawn(function()
        while true do
            --Wait to refresh.
            task.wait(REFRESH_CAN_CHAT_DELAY_SECONDS)

            --Refresh the players in batches.
            --This probably isn't needed, but it is a bit more friendly for resource usage on larger servers.
            local PlayerBatches = {{}}
            for _, Player in Players:GetPlayers() do
                if #PlayerBatches[#PlayerBatches] >= REFRESH_CAN_CHAT_PLAYERS_PER_STEP then
                    table.insert(PlayerBatches, {} :: {Player})
                end
                table.insert(PlayerBatches[#PlayerBatches], Player)
            end

            for _, PlayerBatch in PlayerBatches do
                CanChatReplication:_RefreshPlayers(PlayerBatch)
                task.wait(REFRESH_CAN_CHAT_STEP_DELAY_SECONDS)
            end
        end
    end)
end



return CanChatReplication