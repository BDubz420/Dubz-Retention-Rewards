DRR = DRR or {}
DRR.UI = DRR.UI or {}

local function easeOutQuart(t)
    return 1 - math.pow(1 - t, 4)
end

function DRR.UI.StartSpinAnimation(payload)
    local frame = DRR.UI.MainFrame
    if not IsValid(frame) or not IsValid(frame.WheelPanel) then return end

    frame.WheelPanel.SpinData = {
        started = CurTime(),
        duration = payload.duration,
        from = frame.WheelPanel.Angle or 0,
        to = (payload.rotations * 360) + (payload.index - 1) * (360 / math.max(#DRR.SpinPool, 1)),
        rarity = payload.rarity,
        label = payload.label
    }

    surface.PlaySound("buttons/button14.wav")
end

function DRR.UI.DrawWheel(panel, w, h)
    local seg = math.max(#DRR.SpinPool, 1)
    panel.Angle = panel.Angle or 0

    local sd = panel.SpinData
    if sd then
        local t = math.TimeFraction(sd.started, sd.started + sd.duration, CurTime())
        if t >= 1 then
            panel.Angle = sd.to % 360
            panel.SpinData = nil
            timer.Simple(0.25, function()
                notification.AddLegacy("You won: " .. (sd.label or "Reward"), NOTIFY_GENERIC, 4)
                if DRR.Const.RarityOrder[sd.rarity or "common"] >= DRR.Const.RarityOrder.epic then
                    DRR.UI.DrawConfetti(DRR.UI.MainFrame)
                end
            end)
        else
            panel.Angle = Lerp(easeOutQuart(t), sd.from, sd.to) % 360
        end
    end

    draw.RoundedBox(8, 0, 0, w, h, DRR.Const.Color.panel)
    local cx, cy = w / 2, h / 2
    local r = math.min(w, h) * 0.42

    for i, segData in ipairs(DRR.SpinPool) do
        local ang = math.rad((i - 1) * (360 / seg) + panel.Angle)
        local x = cx + math.cos(ang) * r
        local y = cy + math.sin(ang) * r
        draw.SimpleText(segData.icon or "*", "DRR_Small", x, y, DRR.Util.GetRarityColor(segData.rarity), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText("▲", "DRR_Subtitle", cx, 6, DRR.Const.Color.white, TEXT_ALIGN_CENTER)
end
