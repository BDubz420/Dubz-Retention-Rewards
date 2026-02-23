DRR = DRR or {}
DRR.UI = DRR.UI or {}

function DRR.UI.DrawConfetti(panel)
    if not IsValid(panel) then return end
    panel.ConfettiUntil = CurTime() + 1.6
end

hook.Add("HUDPaint", "DRR_ConfettiPaint", function()
    local p = DRR.UI.MainFrame
    if not IsValid(p) or not p.ConfettiUntil or CurTime() > p.ConfettiUntil then return end
    for i = 1, 30 do
        surface.SetDrawColor(math.random(60, 255), math.random(60, 255), math.random(60, 255), 180)
        surface.DrawRect(math.random(0, ScrW()), math.random(0, ScrH()), 4, 8)
    end
end)
