--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerIcons = require(ReplicatedStorage.Glint.PlayerIcons)

return function()
    describe("The PlayerIcons", function()
        local MockPlayer = {UserId = 1} :: any
        local MockAdornee = Instance.new("Part")
        local OriginalGetAdornee = PlayerIcons.GetAdornee
        beforeEach(function()
            PlayerIcons.GetAdornee = function()
                return MockAdornee
            end
            PlayerIcons._Players = {
                GetPlayers = function()
                    return {MockPlayer}
                end,
            } :: any
        end)

        afterEach(function()
            PlayerIcons.GetAdornee = OriginalGetAdornee
            PlayerIcons._Players = Players :: any
            PlayerIcons._IconsContainer:ClearAllChildren()
            PlayerIcons._PlayerIcons = {}
            PlayerIcons._CanChatIds = {}
        end)

        it("should not create icons for players who can chat.", function()
            PlayerIcons._CanChatIds[1] = true
            PlayerIcons:_UpdateIcon(MockPlayer)

            expect(#PlayerIcons._IconsContainer:GetChildren()).to.equal(0)
            expect(PlayerIcons._PlayerIcons[MockPlayer]).to.equal(nil)
        end)

        it("should add icons for players who can't chat.", function()
            PlayerIcons:_UpdateIcon(MockPlayer)

            expect(#PlayerIcons._IconsContainer:GetChildren()).to.equal(1)
            expect(PlayerIcons._IconsContainer:GetChildren()[1]).to.equal(PlayerIcons._PlayerIcons[MockPlayer])
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)
        end)

        it("should hide icons when the adornee is hidden.", function()
            PlayerIcons:_UpdateIcon(MockPlayer)

            expect(#PlayerIcons._IconsContainer:GetChildren()).to.equal(1)
            expect(PlayerIcons._IconsContainer:GetChildren()[1]).to.equal(PlayerIcons._PlayerIcons[MockPlayer])
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)

            MockAdornee.Transparency = 1
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(nil)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(false)
            
            MockAdornee.Transparency = 0
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(true)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)

            MockAdornee.LocalTransparencyModifier = 1
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(nil)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(false)
            
            MockAdornee.LocalTransparencyModifier = 0
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(true)
        end)

        it("should update icons for players who can't chat.", function()
            PlayerIcons:_UpdateIcon(MockPlayer)
            MockAdornee = Instance.new("Part")
            PlayerIcons:_UpdateIcon(MockPlayer)

            expect(#PlayerIcons._IconsContainer:GetChildren()).to.equal(1)
            expect(PlayerIcons._IconsContainer:GetChildren()[1]).to.equal(PlayerIcons._PlayerIcons[MockPlayer])
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)

            MockAdornee.Transparency = 1
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(nil)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(false)
            
            MockAdornee.Transparency = 0
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(true)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)

            MockAdornee.LocalTransparencyModifier = 1
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(nil)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(false)
            
            MockAdornee.LocalTransparencyModifier = 0
            task.wait()
            expect(PlayerIcons._PlayerIcons[MockPlayer].Adornee).to.equal(MockAdornee)
            expect(PlayerIcons._PlayerIcons[MockPlayer].Enabled).to.equal(true)
        end)

        it("should remove icons for players who can chat.", function()
            PlayerIcons:_UpdateIcon(MockPlayer)

            PlayerIcons._CanChatIds[1] = true
            PlayerIcons:_UpdateIcon(MockPlayer)

            expect(#PlayerIcons._IconsContainer:GetChildren()).to.equal(0)
            expect(PlayerIcons._PlayerIcons[MockPlayer]).to.equal(nil)
        end)

        it("should clear can chat ids when unset.", function()
            PlayerIcons._CanChatIds[1] = true
            PlayerIcons._CanChatIds[3] = true
            PlayerIcons:_UpdateCanChatIds(nil)

            expect(PlayerIcons._CanChatIds[1]).to.equal(nil)
            expect(PlayerIcons._CanChatIds[3]).to.equal(nil)
        end)

        it("should update can chat ids when set.", function()
            PlayerIcons._CanChatIds[1] = true
            PlayerIcons._CanChatIds[3] = true
            PlayerIcons:_UpdateCanChatIds("1,2")

            expect(PlayerIcons._CanChatIds[1]).to.equal(true)
            expect(PlayerIcons._CanChatIds[2]).to.equal(true)
            expect(PlayerIcons._CanChatIds[3]).to.equal(nil)
        end)
    end)
end