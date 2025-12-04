--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CanChatReplication = require(ReplicatedStorage.Glint.CanChatReplication)

return function()
    describe("The CanChatReplication", function()
        local CanChatCalls = 0
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
        local MockPlayer3 = {
            UserId = 3,
            Attributes = {},
            SetAttribute = function(self, Name, Value)
                self.Attributes[Name] = Value
            end,
        } :: any
        local MockPlayer4 = {
            UserId = 4,
        } :: any
        local OriginalCanChat = CanChatReplication._CanChat
        
        beforeEach(function()
            CanChatReplication._Players = {
                GetPlayers = function()
                    return {MockPlayer1, MockPlayer3, MockPlayer4}
                end,
            } :: any

            CanChatReplication._CanChat = function(_, Player1, Player2)
                CanChatCalls += 1
                return Player1.UserId ~= 3 and Player2.UserId ~= 3
            end
        end)

        afterEach(function()
            CanChatCalls = 0
            CanChatReplication._Players = Players :: any
            CanChatReplication._CanChatCache = {}
            CanChatReplication._CanChat = OriginalCanChat
        end)

        it("should refresh players.", function()
            CanChatReplication._CanChatCache = {
                [MockPlayer1] = {1,3}, --Tests that on players that can't be chatted with are updated.
                [MockPlayer2] = {2},
                [MockPlayer3] = {3},
                --Tests that MockPlayer4 isn't updated.
            }

            CanChatReplication:_RefreshPlayers({MockPlayer1, MockPlayer2})
            expect(MockPlayer1.Attributes.CanChatIds).to.equal("1,3,2")
            expect(MockPlayer2.Attributes.CanChatIds).to.equal("2,1")
            expect(MockPlayer3.Attributes.CanChatIds).to.equal("3")
            expect(CanChatCalls).to.equal(2) --1 checks 2, 2 checks only 3 (1 previously checked)
        end)

        it("should initialize players.", function()
            CanChatReplication:_InitializePlayers({MockPlayer1})

            expect(MockPlayer1.Attributes.CanChatIds).to.equal("1,4")
            expect(CanChatCalls).to.equal(3)
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
            expect(CanChatCalls).to.equal(8)
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