--Main module for Glint.
--!strict

local RunService = game:GetService("RunService")

local Glint = {}

export type Glint = typeof(Glint)



--[[
Initializes Glint.
--]]
function Glint.Initialize(self: Glint): ()
    if RunService:IsServer() then
        --Start replication.
        require(script:WaitForChild("CanChatReplication"))
    else
        --TODO
    end
end



return Glint