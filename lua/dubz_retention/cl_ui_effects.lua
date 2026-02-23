DRR = DRR or {}
DRR.UI = DRR.UI or {}

DRR.UI.Theme = {
    bg = Color(7, 10, 14),
    bg2 = Color(11, 16, 24),
    card = Color(15, 22, 33),
    cardHi = Color(20, 28, 41),
    accent = Color(37, 150, 190),
    accentSoft = Color(37, 150, 190, 80),
    text = Color(245, 248, 255),
    muted = Color(150, 168, 190)
}

local matGlow = Material("sprites/light_glow02_add")

function DRR.UI.LerpColor(frac, from, to)
    return Color(
        Lerp(frac, from.r, to.r),
        Lerp(frac, from.g, to.g),
        Lerp(frac, from.b, to.b),
        Lerp(frac, from.a or 255, to.a or 255)
    )
end

function DRR.UI.DrawShadow(x, y, w, h, alpha)
    draw.RoundedBox(16, x + 2, y + 6, w, h, Color(0, 0, 0, alpha or 110))
end

function DRR.UI.DrawGradientHeader(x, y, w, h)
    for i = 0, h do
        local t = i / h
        local c = DRR.UI.LerpColor(t, Color(30, 160, 205), Color(16, 72, 130))
        surface.SetDrawColor(c)
        surface.DrawRect(x, y + i, w, 1)
    end
end

function DRR.UI.DrawGlow(x, y, size, col, alphaMul)
    surface.SetMaterial(matGlow)
    surface.SetDrawColor(col.r, col.g, col.b, (col.a or 255) * (alphaMul or 1))
    surface.DrawTexturedRect(x - size * 0.5, y - size * 0.5, size, size)
end

function DRR.UI.SpawnConfetti(panel, amount)
    if not IsValid(panel) then return end
    panel.DRRConfetti = panel.DRRConfetti or {}
    local w, h = panel:GetSize()
    for _ = 1, (amount or 55) do
        panel.DRRConfetti[#panel.DRRConfetti + 1] = {
            x = math.random(80, w - 80),
            y = math.random(-30, h * 0.35),
            vx = math.Rand(-80, 80),
            vy = math.Rand(55, 180),
            rot = math.Rand(0, 360),
            rs = math.Rand(-160, 160),
            life = CurTime() + math.Rand(0.9, 2.1),
            col = HSVToColor(math.random(170, 220), math.Rand(0.5, 0.9), 1)
        }
    end
end

function DRR.UI.DrawConfetti(panel)
    if not IsValid(panel) or not panel.DRRConfetti then return end
    local now = CurTime()
    for i = #panel.DRRConfetti, 1, -1 do
        local p = panel.DRRConfetti[i]
        if now >= p.life then
            table.remove(panel.DRRConfetti, i)
        else
            local ft = FrameTime()
            p.x = p.x + p.vx * ft
            p.y = p.y + p.vy * ft
            p.vy = p.vy + 160 * ft
            p.rot = p.rot + p.rs * ft

            surface.SetDrawColor(p.col.r, p.col.g, p.col.b, 220)
            surface.DrawRect(p.x, p.y, 5, 9)
        end
    end
end
