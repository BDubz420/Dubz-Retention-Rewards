DRR = DRR or {}
DRR.Analytics = DRR.Analytics or {}

DRR.Analytics.Global = DRR.Analytics.Global or {
    dateKey = DRR.Util.GetUTCDateKey(),
    spinsToday = 0,
    uniqueSpinners = {},
    moneyInjectedToday = 0,
    jackpotHitsToday = 0
}

local function refreshDay()
    local g = DRR.Analytics.Global
    local nowDay = DRR.Util.GetUTCDateKey()
    if g.dateKey ~= nowDay then
        g.dateKey = nowDay
        g.spinsToday = 0
        g.uniqueSpinners = {}
        g.moneyInjectedToday = 0
        g.jackpotHitsToday = 0
    end
end

function DRR.Analytics.RecordSpin(ply, reward, appliedMeta)
    refreshDay()
    local g = DRR.Analytics.Global
    g.spinsToday = g.spinsToday + 1
    g.uniqueSpinners[ply:SteamID64()] = true
    if appliedMeta and appliedMeta.moneyAdded then g.moneyInjectedToday = g.moneyInjectedToday + appliedMeta.moneyAdded end
    if reward and reward.rarity == "jackpot" then g.jackpotHitsToday = g.jackpotHitsToday + 1 end
end

function DRR.Analytics.GetAdminStats()
    refreshDay()
    local count = 0
    for _ in pairs(DRR.Analytics.Global.uniqueSpinners) do count = count + 1 end
    return {
        spinsToday = DRR.Analytics.Global.spinsToday,
        uniqueSpinners = count,
        moneyInjectedToday = DRR.Analytics.Global.moneyInjectedToday,
        jackpotHitsToday = DRR.Analytics.Global.jackpotHitsToday
    }
end
