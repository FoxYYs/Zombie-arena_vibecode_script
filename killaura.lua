local Killaura = {
    Enabled = false,
    Radius = 60,
    Damage = 999999999,
    TickDelay = 0.15
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local controller = nil

local function findController()
    local getgc = getgc or (getreg and function() return getreg() end)
    if not getgc then return nil end

    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Zombies") and rawget(v, "Remotes") then
            if type(v.Zombies) == "table" and type(v.Remotes) == "table" then
                return v
            end
        end
    end
    return nil
end

task.spawn(function()
    while not controller do
        controller = findController()
        if not controller then task.wait(1) end
    end

    while true do
        task.wait(Killaura.TickDelay)
        if not Killaura.Enabled then continue end

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and controller.Remotes.Damage then
            local success, nearby = pcall(function()
                return controller:GetZombiesInRadius(root.Position, Killaura.Radius, false)
            end)

            if success and type(nearby) == "table" then
                for _, data in ipairs(nearby) do
                    if data.Id then
                        controller.Remotes.Damage:FireServer(data.Id, Killaura.Damage)
                    end
                end
            else
                for id, z in pairs(controller.Zombies) do
                    if type(z) == "table" and not z.IsDying then
                        local zPos = z.CurrentPosition or (z.Model and z.Model:GetPivot().Position)
                        if zPos and (zPos - root.Position).Magnitude <= Killaura.Radius then
                            controller.Remotes.Damage:FireServer(id, Killaura.Damage)
                        end
                    end
                end
            end
        end
    end
end)

return Killaura
