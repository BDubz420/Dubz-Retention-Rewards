DRR = DRR or {}
DRR.UI = DRR.UI or {}

function DRR.UI.OpenAdmin()
    if IsValid(DRR.UI.AdminFrame) then DRR.UI.AdminFrame:Remove() end
    local f = vgui.Create("DFrame")
    f:SetSize(460, 360)
    f:Center()
    f:SetTitle("Dubz Retention Admin")
    f:MakePopup()
    DRR.UI.AdminFrame = f

    local stats = vgui.Create("DLabel", f)
    stats:SetPos(16, 36)
    stats:SetSize(430, 120)
    stats:SetWrap(true)
    stats:SetText("Loading stats...")

    local sidEntry = vgui.Create("DTextEntry", f)
    sidEntry:SetPos(16, 170)
    sidEntry:SetSize(220, 28)
    sidEntry:SetPlaceholderText("SteamID64")

    local reset = vgui.Create("DButton", f)
    reset:SetPos(246, 170)
    reset:SetSize(190, 28)
    reset:SetText("Reset Streak")
    reset.DoClick = function()
        net.Start("DR_AdminCmd") net.WriteString("reset_streak") net.WriteString(sidEntry:GetValue()) net.SendToServer()
    end

    local grant = vgui.Create("DButton", f)
    grant:SetPos(16, 206)
    grant:SetSize(420, 28)
    grant:SetText("Grant 1 Token")
    grant.DoClick = function()
        net.Start("DR_AdminCmd") net.WriteString("grant_token") net.WriteString(sidEntry:GetValue()) net.WriteUInt(1, 8) net.SendToServer()
    end

    net.Start("DR_AdminCmd") net.WriteString("get_stats") net.SendToServer()

    f.StatsLabel = stats
end

net.Receive("DR_AdminCmd", function()
    local action = net.ReadString()
    if action == "open" then
        DRR.UI.OpenAdmin()
    elseif action == "stats" then
        local s = net.ReadTable() or {}
        if IsValid(DRR.UI.AdminFrame) and IsValid(DRR.UI.AdminFrame.StatsLabel) then
            DRR.UI.AdminFrame.StatsLabel:SetText(string.format(
                "Spins today: %d\nUnique spinners: %d\nMoney injected today: %d\nJackpot hits today: %d",
                s.spinsToday or 0, s.uniqueSpinners or 0, s.moneyInjectedToday or 0, s.jackpotHitsToday or 0
            ))
        end
    end
end)
