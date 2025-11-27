--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CanChatReplication = require(ReplicatedStorage.Glint.CanChatReplication)

return function()
    describe("The CanChatReplication", function()
        local MockPlayer1 = {
            UserId = 1,
            Attributes = {},
            SetAttribute = function(self, Name, Value)
                self.Attributes[Name] = Value
            end,
        } :: any
        local MockPlayer2 = {
            UserId = 2,
            Attributes = {},
            SetAttribute = function(self, Name, Value)
                self.Attributes[Name] = Value
            end,
        } :: any
        local MockPlayer3, MockPlayer4 = {UserId = 3} :: any, {UserId = 4} :: any
        local OriginalCanChat = CanChatReplication._CanChat
        
        beforeEach(function()
            CanChatReplication._Players = {
                GetPlayers = function()
                    return {MockPlayer1, MockPlayer3, MockPlayer4}
                end,
            } :: any

            CanChatReplication._CanChat = function(_, Player1, Player2)
                return Player2.UserId ~= 3
            end
        end)

        afterEach(function()
            CanChatReplication._Players = Players :: any
            CanChatReplication._CanChatCache = {}
            CanChatReplication._CanChat = OriginalCanChat
        end)

        it("should initialize players.", function()
            CanChatReplication:_InitializePlayers({MockPlayer1})

            expect(MockPlayer1.Attributes.CanChatIds).to.equal("1,4")
        end)

        it("should initialize additional players.", function()
            CanChatReplication:_InitializePlayers({MockPlayer1})

            CanChatReplication._Players = {
                GetPlayers = function()
                    return {MockPlayer1, MockPlayer2, MockPlayer3, MockPlayer4}
                end,
            } :: any
            CanChatReplication:_InitializePlayers({MockPlayer2})

            expect(MockPlayer1.Attributes.CanChatIds).to.equal("1,4,2")
            expect(MockPlayer2.Attributes.CanChatIds).to.equal("1,2,4")
        end)

        it("should uninitialize players.", function()
            CanChatReplication:_InitializePlayers({MockPlayer1})

            CanChatReplication._Players = {
                GetPlayers = function()
                    return {MockPlayer1, MockPlayer2, MockPlayer3, MockPlayer4}
                end,
            } :: any
            CanChatReplication:_InitializePlayers({MockPlayer2})

            CanChatReplication._Players = {
                GetPlayers = function()
                    return {MockPlayer1, MockPlayer2, MockPlayer3}
                end,
            } :: any
            CanChatReplication:_UninitializePlayer(MockPlayer4)

            expect(MockPlayer1.Attributes.CanChatIds).to.equal("1,2")
            expect(MockPlayer2.Attributes.CanChatIds).to.equal("1,2")
        end)
    end)
end