# Glint
Indicates if you can chat with other players by adding an icon above
characters you can't chat with.

# Setup
Glint needs to be initialized on the client and server. **The setup
is the same**.

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Glint = require(ReplicatedStorage.Glint)

Glint:Initialize()
```

## Customization
On the client, the setup for icons is intended to be modular. When updating,
make sure to check if the options changed.

```luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Glint = require(ReplicatedStorage.Glint)

--Changes BillboardGui properties.
Glint.IconFactory.IconBillboardGuiSize = UDim2.new(0, 50, 0, 50)
Glint.IconFactory.IconBillboardGuiStudsOffset = Vector3.new(0, 5, 0)
Glint.IconFactory.IconMaxDistance = 50

--Changes the icon images.
Glint.IconFactory.IconParts = {
    {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(255, 255, 0),
        Image = "rbxassetid://12345",
    },
}

--Apply changes to BillboardGuis after creation.
local OriginalCreateIcon = Glint.IconFactory.CreateIcon
Glint.IconFactory.CreateIcon = function(Player: Player): BillboardGui
    local BillboardGui = OriginalCreateIcon(Player)
    BillboardGui.Name = "MyChangedProperty"
    return BillboardGui
end

--Changes the adornee, meant for custom characters.
Glint.PlayerIcons.GetAdornee = function(Player: Player): BasePart?
    return Instance.new("Part")
end

local MyCustomCharacterLoaded = Instance.new("BindableEvent")
Glint.PlayerIcons.GetAdorneeUpdateEvent = function(Player: Player): RBXScriptSignal
    return MyCustomCharacterLoaded.Event
end

--Initialize on the client AFTER the setup.
Glint:Initialize()
```

# License
This project is available under the terms of the MIT License. See [LICENSE](LICENSE)
for details.