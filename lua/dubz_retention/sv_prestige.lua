DRR = DRR or {}

function DRR.HandlePrestige(ply)
    local d = DRR.GetPlayerData(ply)
    if (tonumber(d.streak) or 0) >= DRR.Config.PrestigeStreakRequirement then
        d.prestige = math.max(tonumber(d.prestige) or 0, 0) + 1
        d.streak = 1
        net.Start("DR_Toast")
            net.WriteString("Prestige up! Level " .. d.prestige)
        net.Send(ply)
    end
end

function DRR.GetRewardMultipliers(ply, data)
    local m = {
        money = tonumber(DRR.Config.MoneyScale) or 1,
        streak = 1
    }

    if DRR.Util.HasVIP(ply) then
        m.money = m.money * (tonumber(DRR.Config.VIPMoneyMultiplier) or 1)
    end

    local pBonus = math.min((tonumber(data.prestige) or 0) * DRR.Config.PrestigeMoneyBonusPerLevel, DRR.Config.PrestigeMoneyBonusMax)
    m.money = m.money * (1 + pBonus)

    for _, tier in ipairs(DRR.Config.StreakMoneyMultiplierTiers or {}) do
        if (tonumber(data.streak) or 0) >= (tonumber(tier.min) or 0) then
            m.streak = tonumber(tier.mult) or m.streak
        end
    end

    m.money = m.money * m.streak
    return m
end
