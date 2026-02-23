DRR = DRR or {}
DRR.UI = DRR.UI or {}
DRR.ClientSnapshot = DRR.ClientSnapshot or {}

local function fmtMins(sec)
    sec = math.max(math.floor(sec or 0), 0)
    return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
end

local function createButton(parent, text)
    local b = vgui.Create("DButton", parent)
    b:SetText("")
    b.Label = text
    b.Hov = 0
    b.Dis = false
    b.Paint = function(self, w, h)
        self.Hov = Lerp(FrameTime() * 10, self.Hov, self:IsHovered() and 1 or 0)
        local base = self.Dis and Color(60, 70, 85) or DRR.UI.LerpColor(self.Hov, Color(23, 94, 130), DRR.UI.Theme.accent)
        DRR.UI.DrawShadow(0, 0, w, h, 80)
        draw.RoundedBox(12, 0, 0, w, h, base)
        if not self.Dis then
            DRR.UI.DrawGlow(w * 0.5, h * 0.5, 150 + self.Hov * 40, DRR.UI.Theme.accent, 0.17)
        end
        local bounce = math.sin(CurTime() * 8) * 1.2 * self.Hov
        draw.SimpleText(self.Label, "DRR_Font_Button", w * 0.5, h * 0.5 - 11 + bounce, Color(242, 248, 255), TEXT_ALIGN_CENTER)
    end
    return b
end

local function drawStatCard(x, y, w, h, title, value, progress)
    DRR.UI.DrawShadow(x, y, w, h, 65)
    draw.RoundedBox(14, x, y, w, h, DRR.UI.Theme.card)
    draw.SimpleText(title, "DRR_Font_Small", x + 14, y + 10, DRR.UI.Theme.muted)
    draw.SimpleText(value, "DRR_Font_Heading", x + 14, y + 31, DRR.UI.Theme.text)

    if progress then
        local barW, barH = w - 28, 8
        draw.RoundedBox(4, x + 14, y + h - 18, barW, barH, Color(34, 42, 56))
        draw.RoundedBox(4, x + 14, y + h - 18, barW * math.Clamp(progress, 0, 1), barH, DRR.UI.Theme.accent)
    end
end

function DRR.UI.OpenMain()
    if IsValid(DRR.UI.MainFrame) then DRR.UI.MainFrame:Remove() end

    local f = vgui.Create("DFrame")
    f:SetSize(900, 600)
    f:Center()
    f:SetTitle("")
    f:ShowCloseButton(false)
    f:MakePopup()
    f.Alpha = 0
    DRR.UI.MainFrame = f

    local close = vgui.Create("DButton", f)
    close:SetText("")
    close:SetSize(34, 34)
    close:SetPos(f:GetWide() - 42, 12)
    close.Paint = function(self, w, h)
        local hv = self:IsHovered() and 1 or 0
        draw.RoundedBox(8, 0, 0, w, h, hv == 1 and Color(220, 70, 70) or Color(40, 47, 60))
        draw.SimpleText("×", "DRR_Font_Heading", w * 0.5, 2, Color(245, 245, 245), TEXT_ALIGN_CENTER)
    end
    close.DoClick = function() f:Close() end

    local spinBtn = createButton(f, "SPIN")
    spinBtn:SetSize(260, 56)
    spinBtn:SetPos(560, 522)

    local weeklyBtn = createButton(f, "CLAIM WEEKLY")
    weeklyBtn:SetSize(220, 42)
    weeklyBtn:SetPos(322, 530)

    spinBtn.DoClick = function(self)
        if self.Dis then return end
        net.Start("DR_RequestSpin")
        net.SendToServer()
        self.Dis = true
    end

    weeklyBtn.DoClick = function()
        net.Start("DR_AdminCmd")
            net.WriteString("claim_weekly")
        net.SendToServer()
    end

    local wheel = vgui.Create("DPanel", f)
    wheel:SetPos(312, 92)
    wheel:SetSize(570, 420)
    wheel.Paint = DRR.UI.DrawWheel
    f.WheelPanel = wheel

    local stats = vgui.Create("DPanel", f)
    stats:SetPos(20, 92)
    stats:SetSize(280, 488)
    stats.Paint = function(_, w, h)
        DRR.UI.DrawShadow(0, 0, w, h, 80)
        draw.RoundedBox(16, 0, 0, w, h, DRR.UI.Theme.bg2)

        local s = DRR.ClientSnapshot or {}
        local allowed = s.allowedSpinsToday or 0
        local claimed = s.spinsClaimedToday or 0
        local avail = math.max(allowed - claimed, 0)
        local weeklyCount = table.Count((s.weekly and s.weekly.daysLogged) or {})

        drawStatCard(12, 12, w - 24, 74, "Daily Streak", tostring(s.streak or 0), math.min((s.streak or 0) / 30, 1))
        drawStatCard(12, 94, w - 24, 74, "Prestige Level", tostring(s.prestige or 0), math.min((s.prestige or 0) / 10, 1))
        drawStatCard(12, 176, w - 24, 74, "Protection Tokens", tostring(s.tokens or 0))
        drawStatCard(12, 258, w - 24, 74, "Spins Available", tostring(avail), allowed > 0 and (avail / allowed) or 0)

        local pt = tonumber(s.playtimeTodaySeconds) or 0
        local target = (DRR.Config.PlaytimeSpinThresholdsMinutes[1] or 60) * 60
        for _, mins in ipairs(DRR.Config.PlaytimeSpinThresholdsMinutes or {}) do
            local t = mins * 60
            if pt < t then target = t break end
        end

        drawStatCard(12, 340, w - 24, 74, "Next Bonus Spin", fmtMins(math.max(target - pt, 0)), math.Clamp(pt / target, 0, 1))
        drawStatCard(12, 422, w - 24, 54, "Weekly Progress", string.format("%d / %d", weeklyCount, DRR.Config.WeeklyRequiredDays), weeklyCount / DRR.Config.WeeklyRequiredDays)
    end

    f.Paint = function(self, w, h)
        self.Alpha = Lerp(FrameTime() * 7, self.Alpha, 1)
        surface.SetAlphaMultiplier(self.Alpha)

        DRR.UI.DrawShadow(0, 0, w, h, 120)
        draw.RoundedBox(18, 0, 0, w, h, DRR.UI.Theme.bg)

        DRR.UI.DrawGradientHeader(0, 0, w, 72)
        draw.SimpleText("Dubz Retention Rewards", "DRR_Font_Title", 20, 17, color_white)

        local prestige = DRR.ClientSnapshot and DRR.ClientSnapshot.prestige or 0
        local badgeW, badgeH = 140, 34
        local bx, by = w - badgeW - 58, 20
        draw.RoundedBox(18, bx, by, badgeW, badgeH, Color(10, 20, 35, 140))
        draw.SimpleText("PRESTIGE " .. prestige, "DRR_Font_Small", bx + badgeW * 0.5, by + 9, color_white, TEXT_ALIGN_CENTER)

        surface.SetAlphaMultiplier(1)
        DRR.UI.PaintReveal(self, w, h)
        DRR.UI.DrawConfetti(self)
    end

    local canSpin = (DRR.ClientSnapshot.spinsClaimedToday or 0) < (DRR.ClientSnapshot.allowedSpinsToday or 0)
    spinBtn.Dis = not canSpin
end

net.Receive("DR_OpenMenu", function()
    DRR.UI.OpenMain()
end)

net.Receive("DR_DataSnapshot", function()
    DRR.ClientSnapshot = net.ReadTable() or {}
    if IsValid(DRR.UI.MainFrame) then
        DRR.UI.OpenMain()
    end
end)

net.Receive("DR_SpinResult", function()
    local payload = {
        resultIndex = net.ReadUInt(8),
        label = net.ReadString(),
        rarity = net.ReadString(),
        icon = net.ReadString(),
        spinDuration = net.ReadFloat(),
        fullRotations = net.ReadUInt(8),
        startAngle = net.ReadFloat(),
        sliceTable = DRR.SpinPool
    }
    DRR.UI.StartSpinAnimation(payload)
end)

net.Receive("DR_Toast", function()
    notification.AddLegacy(net.ReadString(), NOTIFY_GENERIC, 4)
end)
