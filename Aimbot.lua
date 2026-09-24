-- Script com Teleporte + Silent Aim nos Players

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Configuração do Silent Aim
local SilentAimEnabled = true
local MaxDistance = 200 -- Distância máxima para puxar o Silent Aim

-- Função para achar o player mais próximo da mira/mouse
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(pos.X, pos.Y)
                local distance = (mousePos - targetPos).Magnitude

                if distance < shortestDistance and distance < MaxDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Hook para redirecionar as habilidades/ataques no alvo (Silent Aim)
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Intercepta quando o script envia a posição do ataque para o servidor
    if SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- Redireciona o vetor/posição para o RootPart do player focado
            for i, arg in ipairs(args) do
                if typeof(arg) == "Vector3" then
                    args[i] = target.Character.HumanoidRootPart.Position
                elseif typeof(arg) == "CFrame" then
                    args[i] = target.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)
setreadonly(gmt, true)
