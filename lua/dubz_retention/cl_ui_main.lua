DRR = DRR or {}
DRR.UI = DRR.UI or {}
DRR.ClientSnapshot = DRR.ClientSnapshot or {}

local function fmtTime(sec)
    sec = math.max(math.floor(sec or 0), 0)
    return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
end

function DRR.UI.OpenMain()
    if IsValid(DRR.UI.MainFrame) then DRR.UI.MainFrame:Remove() end

    local f = vgui.Create("DFrame")
    f:SetSize(860, 560)
    f:Center()
    f:SetTitle("")
    f:MakePopup()
    f.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, DRR.Const.Color.bg)
        draw.SimpleText("Dubz Retention Rewards", "DRR_Title", 20, 14, DRR.Const.Color.white)
    end
    DRR.UI.MainFrame = f

    local left = vgui.Create("DPanel", f)
    left:SetPos(16, 56)
    left:SetSize(300, 488)
    left.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, DRR.Const.Color.panel)
        local s = DRR.ClientSnapshot
        draw.SimpleText("Streak: " .. (s.streak or 0), "DRR_Subtitle", 12, 12, DRR.Const.Color.white)
        draw.SimpleText("Prestige: " .. (s.prestige or 0), "DRR_Body", 12, 42, DRR.Const.Color.blue)
        draw.SimpleText("Tokens: " .. (s.tokens or 0), "DRR_Body", 12, 66, DRR.Const.Color.white)
        draw.SimpleText("Spins: " .. (s.spinsClaimedToday or 0) .. "/" .. (s.allowedSpinsToday or 0), "DRR_Body", 12, 90, DRR.Const.Color.white)

        local pt = tonumber(s.playtimeTodaySeconds) or 0
        local nextTarget = 3600
        for _, m in ipairs(DRR.Config.PlaytimeSpinThresholdsMinutes) do
            local sec = m * 60
            if pt < sec then nextTarget = sec break end
        end
        draw.SimpleText("Next bonus spin in " .. fmtTime(math.max(nextTarget - pt, 0)), "DRR_Small", 12, 122, DRR.Const.Color.white)
        local weeklyCount = table.Count((s.weekly and s.weekly.daysLogged) or {})
        draw.SimpleText("Weekly: " .. weeklyCount .. "/" .. DRR.Config.WeeklyRequiredDays, "DRR_Body", 12, 150, DRR.Const.Color.white)
    end

    local wheel = vgui.Create("DPanel", f)
    wheel:SetPos(330, 56)
    wheel:SetSize(514, 420)
    wheel.Paint = DRR.UI.DrawWheel
    f.WheelPanel = wheel

    local spin = vgui.Create("DButton", f)
    spin:SetPos(330, 486)
    spin:SetSize(250, 44)
    spin:SetText("Spin Daily Wheel")
    spin:SetEnabled((DRR.ClientSnapshot.spinsClaimedToday or 0) < (DRR.ClientSnapshot.allowedSpinsToday or 0))
    spin.DoClick = function()
        net.Start("DR_RequestSpin")
        net.SendToServer()
        spin:SetEnabled(false)
    end

    local weekly = vgui.Create("DButton", f)
    weekly:SetPos(594, 486)
    weekly:SetSize(250, 44)
    weekly:SetText("Claim Weekly Crate")
    weekly.DoClick = function()
        net.Start("DR_AdminCmd")
            net.WriteString("claim_weekly")
        net.SendToServer()
    end
end

net.Receive("DR_OpenMenu", function() DRR.UI.OpenMain() end)
net.Receive("DR_DataSnapshot", function()
    DRR.ClientSnapshot = net.ReadTable() or {}
    if IsValid(DRR.UI.MainFrame) then DRR.UI.OpenMain() end
end)

net.Receive("DR_SpinResult", function()
    local payload = {
        index = net.ReadUInt(8),
        label = net.ReadString(),
        rarity = net.ReadString(),
        icon = net.ReadString(),
        duration = net.ReadFloat(),
        rotations = net.ReadUInt(8),
        start = net.ReadFloat()
    }
    DRR.UI.StartSpinAnimation(payload)
end)

net.Receive("DR_Toast", function()
    notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, 4)
end)
