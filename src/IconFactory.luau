--Creates icons.
--!strict

local ICON_BILLBOARD_GUI_SIZE = UDim2.new(1, 0, 1, 0)
local ICON_BILLBOARD_GUI_STUDS_OFFSET = Vector3.new(0, 2.5, 0)
local ICON_MAX_DISTANCE = 100
local ICON_LIGHT_INFLUENCE = 0
local ICON_SPRITE = "rbxassetid://129968335185996"
local ICON_PARTS = {
    {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        Image = ICON_SPRITE,
        ImageRectSize = Vector2.new(128, 128),
        ImageRectOffset = Vector2.new(0, 0),
    },
    {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(255, 0, 0),
        Image = ICON_SPRITE,
        ImageRectSize = Vector2.new(128, 128),
        ImageRectOffset = Vector2.new(0, 128),
    },
} :: {{[string]: any}}

local IconFactory = {}
IconFactory.IconBillboardGuiSize = ICON_BILLBOARD_GUI_SIZE
IconFactory.IconBillboardGuiStudsOffset = ICON_BILLBOARD_GUI_STUDS_OFFSET
IconFactory.IconMaxDistance = ICON_MAX_DISTANCE
IconFactory.IconLightInfluence = ICON_LIGHT_INFLUENCE
IconFactory.IconParts = ICON_PARTS

export type IconFactory = typeof(IconFactory)



--[[
Creates the child elements of the icon.
--]]
function IconFactory.CreateChildFrames(): {Instance}
    local Images = {} :: {Instance}
    for _, ImageData in IconFactory.IconParts do
        local ImageLabel = Instance.new("ImageLabel")
        for Name, Value in ImageData do
            (ImageLabel :: any)[Name] = Value
        end
        table.insert(Images, ImageLabel)
    end
    return Images
end

--[[
Creates the BillboardGui icon.
--]]
function IconFactory.CreateIcon(Player: Player): BillboardGui
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = `GlintNoChatIcon_{Player.UserId}`
    BillboardGui.ResetOnSpawn = false
    BillboardGui.MaxDistance = IconFactory.IconMaxDistance
    BillboardGui.Size = IconFactory.IconBillboardGuiSize
    BillboardGui.LightInfluence = IconFactory.IconLightInfluence
    BillboardGui.StudsOffsetWorldSpace = IconFactory.IconBillboardGuiStudsOffset

    for _, Image in IconFactory.CreateChildFrames() do
        Image.Parent = BillboardGui
    end

    return BillboardGui
end



return IconFactory