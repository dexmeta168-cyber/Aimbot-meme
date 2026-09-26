local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Variáveis de Controle
_G.SelectedPlayerName = ""
_G.TargetSilentAimEnabled = false

-- Função para listar os jogadores do servidor (exceto você)
local function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- =======================================================
-- INTERFACE GRÁFICA (RAYFIELD UI)
-- =======================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Meme Sea - Target Silent Aim",
   LoadingTitle = "Iniciando...",
   ConfigurationSaving = { Enabled = false }
})

local TabTarget = Window:CreateTab("Player Target", 4483362458)

-- Dropdown para escolher o jogador alvo
local PlayerDropdown = TabTarget:CreateDropdown({
   Name = "Selecionar Jogador Alvo",
   Options = GetPlayerList(),
   CurrentOption = {"Nenhum"},
   MultipleOptions = false,
   Callback = function(Option)
       if type(Option) == "table" then
           _G.SelectedPlayerName = Option[1]
       else
           _G.SelectedPlayerName = Option
       end
   end,
})

-- Botão para atualizar a lista se entrar/sair alguém
TabTarget:CreateButton({
   Name = "Atualizar Lista de Jogadores",
   Callback = function()
       PlayerDropdown:Refresh(GetPlayerList())
   end,
})

-- Toggle para ligar/desligar o Silent Aim no Player selecionado
TabTarget:CreateToggle({
   Name = "Ativar Silent Aim no Alvo",
   CurrentValue = false,
   Callback = function(Value)
       _G.TargetSilentAimEnabled = Value
   end,
})

-- =======================================================
-- LÓGICA DO SILENT AIM (HOOK DO MOUSE)
-- =======================================================
local MetaTable = getrawmetatable(game)
local OldIndex = MetaTable.__index
setreadonly(MetaTable, false)

MetaTable.__index = newcclosure(function(self, Index)
    -- Intercepta as chamadas de "Hit" e "Target" do Mouse do jogador local
    if _G.TargetSilentAimEnabled and not checkcaller() and self == LocalPlayer:GetMouse() then
        if Index == "Hit" or Index == "Target" then
            if _G.SelectedPlayerName ~= "" and _G.SelectedPlayerName ~= "Nenhum" then
                local targetPlayer = Players:FindFirstChild(_G.SelectedPlayerName)
                
                -- Verifica se o jogador alvo existe, tem personagem e está vivo
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid and targetHumanoid.Health > 0 then
                        local targetHead = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character.HumanoidRootPart
                        
                        -- Redireciona a posição do ataque diretamente para a cabeça do jogador selecionado
                        return Index == "Hit" and targetHead.CFrame or targetHead
                    end
                end
            end
        end
    end
    return OldIndex(self, Index)
end)

setreadonly(MetaTable, true)

-- Atualização automática no Dropdown quando entra ou sai alguém
Players.PlayerAdded:Connect(function()
    PlayerDropdown:Refresh(GetPlayerList())
end)

Players.PlayerRemoving:Connect(function()
    PlayerDropdown:Refresh(GetPlayerList())
end)
