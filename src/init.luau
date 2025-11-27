--Main module for Glint.
--!strict

local RunService = game:GetService("RunService")

local IconFactory = require(script:WaitForChild("IconFactory"))
local PlayerIcons = require(script:WaitForChild("PlayerIcons"))

local Glint = {}
Glint.IconFactory = IconFactory
Glint.PlayerIcons = PlayerIcons

export type IconFactory = IconFactory.IconFactory
export type Glint = typeof(Glint)



--[[
Initializes Glint.
--]]
function Glint.Initialize(self: Glint): ()
    if RunService:IsServer() then
        --Start replication.
        require(script:WaitForChild("CanChatReplication"))
    else
        --Create the icons.
        PlayerIcons:Initialize()
    end
end



return Glint