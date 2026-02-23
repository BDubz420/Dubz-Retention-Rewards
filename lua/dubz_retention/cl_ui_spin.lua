DRR = DRR or {}
DRR.UI = DRR.UI or {}

local function easeOutQuart(t)
    return 1 - math.pow(1 - t, 4)
end

local function rarityRank(r)
    return (DRR.Const.RarityOrder and DRR.Const.RarityOrder[r]) or 1
end

local function getSliceColor(rarity)
    local c = DRR.Util.GetRarityColor(rarity)
    return Color(c.r, c.g, c.b, 230)
end

local function drawSegment(cx, cy, inner, outer, a0, a1, col)
    local p1 = {x = cx + math.cos(a0) * inner, y = cy + math.sin(a0) * inner}
    local p2 = {x = cx + math.cos(a0) * outer, y = cy + math.sin(a0) * outer}
    local p3 = {x = cx + math.cos(a1) * outer, y = cy + math.sin(a1) * outer}
    local p4 = {x = cx + math.cos(a1) * inner, y = cy + math.sin(a1) * inner}

    surface.SetDrawColor(col)
    surface.DrawPoly({p1, p2, p3, p4})
end

function DRR.UI.StartSpinAnimation(payload)
    local frame = DRR.UI.MainFrame
    if not IsValid(frame) or not IsValid(frame.WheelPanel) then return end

    local segCount = math.max(#(payload.sliceTable or DRR.SpinPool or {}), 1)
    local sliceSize = 360 / segCount
    local fromAngle = frame.WheelPanel.Angle or 0
    local centerLocal = (payload.resultIndex - 0.5) * sliceSize
    local targetAngle = (-90 - centerLocal) + (payload.fullRotations * 360)

    frame.WheelPanel.SpinData = {
        started = CurTime(),
        duration = payload.spinDuration,
        from = fromAngle,
        to = targetAngle,
        slices = payload.sliceTable or DRR.SpinPool,
        resultIndex = payload.resultIndex,
        rarity = payload.rarity,
        label = payload.label,
        icon = payload.icon,
        finished = false,
        lastTickSeg = nil
    }

    surface.PlaySound("dubstep_zoo/slots/spin.wav")
end

function DRR.UI.DrawWheel(panel, w, h)
    local slices = DRR.SpinPool or {}
    local segCount = math.max(#slices, 1)
    local segDeg = 360 / segCount
    local cx, cy = w * 0.5, h * 0.5
    local outer = math.min(w, h) * 0.46
    local inner = outer * 0.22

    panel.Angle = panel.Angle or 0
    panel.IdleShine = (panel.IdleShine or 0) + FrameTime() * 35

    local sd = panel.SpinData
    if sd then
        local t = math.TimeFraction(sd.started, sd.started + sd.duration, CurTime())
        local anim = math.Clamp(easeOutQuart(t), 0, 1)
        panel.Angle = Lerp(anim, sd.from, sd.to)

        local pointerDeg = ((-90 - panel.Angle) % 360)
        local segNow = math.floor(pointerDeg / segDeg) + 1
        if sd.lastTickSeg ~= segNow then
            sd.lastTickSeg = segNow
            surface.PlaySound("garrysmod/content_downloaded.wav")
            local active = slices[segNow]
            if active and rarityRank(active.rarity) >= rarityRank("rare") then
                panel.RarePulse = CurTime() + 0.08
            end
        end

        if t >= 1 and not sd.finished then
            sd.finished = true
            panel.Angle = sd.to % 360
            timer.Simple(0.25, function()
                if not IsValid(panel) or not IsValid(DRR.UI.MainFrame) then return end
                DRR.UI.ShowRewardReveal({
                    label = sd.label,
                    rarity = sd.rarity,
                    icon = sd.icon
                })
            end)
            panel.SpinData = nil
        end
    end

    DRR.UI.DrawShadow(8, 8, w - 16, h - 16, 90)
    draw.RoundedBox(16, 8, 8, w - 16, h - 16, DRR.UI.Theme.card)

    DRR.UI.DrawGlow(cx, cy, outer * 2.25, DRR.UI.Theme.accent, 0.23)

    for i, slice in ipairs(slices) do
        local a0 = math.rad(((i - 1) * segDeg) + panel.Angle)
        local a1 = math.rad((i * segDeg) + panel.Angle)
        local mid = (a0 + a1) * 0.5
        local col = getSliceColor(slice.rarity)

        drawSegment(cx, cy, inner, outer, a0, a1, col)
        drawSegment(cx, cy, inner, outer * 0.98, a0, a1, Color(0, 0, 0, 20))

        local txr = Lerp(0.58, inner, outer)
        local tx = cx + math.cos(mid) * txr
        local ty = cy + math.sin(mid) * txr
        draw.SimpleText((slice.label or "Reward"):upper(), "DRR_Font_Small", tx, ty, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if rarityRank(slice.rarity) >= rarityRank("rare") then
            DRR.UI.DrawGlow(cx + math.cos(mid) * outer * 0.92, cy + math.sin(mid) * outer * 0.92, 34, col, 0.35)
        end
    end

    surface.SetDrawColor(255, 255, 255, 16)
    for ring = 1, 3 do
        surface.DrawCircle(cx, cy, outer - (ring * 2), 255, 255, 255, 30 - ring * 7)
    end

    local sweep = (panel.IdleShine % 360)
    local a = math.rad(sweep + panel.Angle)
    surface.SetDrawColor(255, 255, 255, 16)
    surface.DrawLine(cx, cy, cx + math.cos(a) * outer, cy + math.sin(a) * outer)

    local hub = {}
    for n = 0, 40 do
        local a = math.rad((n / 40) * 360)
        hub[#hub + 1] = {x = cx + math.cos(a) * inner, y = cy + math.sin(a) * inner}
    end
    draw.NoTexture()
    surface.SetDrawColor(30, 36, 48, 255)
    surface.DrawPoly(hub)
    DRR.UI.DrawGlow(cx, cy, inner * 2.4, DRR.UI.Theme.accent, 0.35)
    draw.SimpleText("DUBZ", "DRR_Font_Heading", cx, cy, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.NoTexture()
    local tri = {
        {x = cx, y = 20},
        {x = cx - 15, y = 48},
        {x = cx + 15, y = 48}
    }
    surface.SetDrawColor(240, 247, 255, 255)
    surface.DrawPoly(tri)

    if panel.RarePulse and CurTime() < panel.RarePulse then
        draw.RoundedBox(16, 8, 8, w - 16, h - 16, Color(80, 160, 210, 25))
    end
end

function DRR.UI.ShowRewardReveal(data)
    local frame = DRR.UI.MainFrame
    if not IsValid(frame) then return end

    local rarity = data.rarity or "common"
    local border = DRR.Util.GetRarityColor(rarity)
    frame.Reveal = {
        started = CurTime(),
        rarity = rarity,
        label = data.label or "Reward",
        icon = data.icon or "*",
        border = border,
        value = 0,
        target = tonumber(string.match(data.label or "", "%d+")) or 0
    }

    local rv = rarityRank(rarity)
    if rv >= rarityRank("epic") then
        DRR.UI.SpawnConfetti(frame, 80)
    end
    if rv >= rarityRank("legendary") then
        util.ScreenShake(LocalPlayer():GetPos(), 2.5, 2.2, 0.35, 250)
    end

    surface.PlaySound(rv >= rarityRank("epic") and "garrysmod/save_load4.wav" or "garrysmod/content_downloaded.wav")
end

function DRR.UI.PaintReveal(frame, w, h)
    local reveal = frame.Reveal
    if not reveal then return end

    local t = math.TimeFraction(reveal.started, reveal.started + 0.3, CurTime())
    local alpha = math.Clamp(t * 255, 0, 210)
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawRect(0, 0, w, h)

    local cw, ch = 420, 230
    local cx, cy = w * 0.5 - cw * 0.5, h * 0.5 - ch * 0.5
    local pop = Lerp(math.min(t, 1), 0.9, 1)
    cw, ch = cw * pop, ch * pop
    cx, cy = w * 0.5 - cw * 0.5, h * 0.5 - ch * 0.5

    DRR.UI.DrawGlow(w * 0.5, h * 0.5, 430, DRR.UI.Theme.accent, 0.2)
    draw.RoundedBox(18, cx, cy, cw, ch, DRR.UI.Theme.cardHi)
    draw.RoundedBox(18, cx, cy, cw, 4, reveal.border)

    draw.SimpleText("REWARD", "DRR_Font_Small", w * 0.5, cy + 22, DRR.UI.Theme.muted, TEXT_ALIGN_CENTER)
    draw.SimpleText(reveal.icon, "DRR_Font_Title", w * 0.5, cy + 68, color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText(reveal.label, "DRR_Font_Reward", w * 0.5, cy + 116, color_white, TEXT_ALIGN_CENTER)

    if reveal.target > 0 then
        reveal.value = Lerp(FrameTime() * 5, reveal.value, reveal.target)
        draw.SimpleText("$" .. math.floor(reveal.value), "DRR_Font_Heading", w * 0.5, cy + 165, reveal.border, TEXT_ALIGN_CENTER)
    end

    if CurTime() - reveal.started > 2.9 then
        frame.Reveal = nil
    end
end
