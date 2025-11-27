--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IconFactory = require(ReplicatedStorage.Glint.IconFactory)

return function()
    describe("The IconFactory", function()
        it("should create images.", function()
            local Images = IconFactory.CreateChildFrames()

            local Image1 = Images[1] :: ImageLabel
            expect(Image1.BackgroundTransparency).to.equal(1)
            expect(Image1.Size).to.equal(UDim2.new(1, 0, 1, 0))
            expect(Image1.ImageColor3).to.equal(Color3.fromRGB(0, 0, 0))
            expect(Image1.Image).to.equal("rbxassetid://129968335185996")
            expect(Image1.ImageRectSize).to.equal(Vector2.new(128, 128))
            expect(Image1.ImageRectOffset).to.equal(Vector2.new(0, 0))

            local Image2 = Images[2] :: ImageLabel
            expect(Image2.BackgroundTransparency).to.equal(1)
            expect(Image2.Size).to.equal(UDim2.new(1, 0, 1, 0))
            expect(Image2.ImageColor3).to.equal(Color3.fromRGB(255, 0, 0))
            expect(Image2.Image).to.equal("rbxassetid://129968335185996")
            expect(Image2.ImageRectSize).to.equal(Vector2.new(128, 128))
            expect(Image2.ImageRectOffset).to.equal(Vector2.new(0, 128))
        end)

        it("should create BillboardGui icons.", function()
            local BillboardGui = IconFactory.CreateIcon({UserId = 123} :: any)
            expect(BillboardGui.Name).to.equal("GlintNoChatIcon_123")
            expect(BillboardGui.ResetOnSpawn).to.equal(false)
            expect(BillboardGui.MaxDistance).to.equal(100)
            expect(BillboardGui.Size).to.equal(UDim2.new(1, 0, 1, 0))
            expect(BillboardGui.LightInfluence).to.equal(0)
            expect(BillboardGui.StudsOffsetWorldSpace).to.equal(Vector3.new(0, 2.5, 0))
            expect(#BillboardGui:GetChildren()).to.equal(2)
        end)
    end)
end