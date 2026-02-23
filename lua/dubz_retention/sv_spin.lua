DRR = DRR or {}

local hasDarkRP = DarkRP and DarkRP.formatMoney
if not hasDarkRP then
    DRR.Log("DarkRP not detected; money rewards will be skipped.")
end

function DRR.DailyResetIfNeeded(ply)
    local d = DRR.GetPlayerData(ply)
    local today = DRR.Util.GetUTCDateKey()
    if d.lastSpinDate ~= today then
        d.lastSpinDate = today
        d.spinsClaimedToday = 0
        d.extraSpinsToday = 0
        d.playtimeTodaySeconds = 0
        d.playtimeRewardedTiers = {}
    end
end

function DRR.ApplyReward(ply, reward, multipliers, meta)
    if not IsValid(ply) or not istable(reward) then return false end
    multipliers = multipliers or {money = 1}
    meta = meta or {}

    local rtype = reward.type
    if rtype == "money" then
        if not hasDarkRP then return false end
        local amount = math.floor((tonumber(reward.amount) or 0) * (tonumber(multipliers.money) or 1))
        if amount <= 0 then return false end
        ply:addMoney(amount)
        meta.moneyAdded = (meta.moneyAdded or 0) + amount
        return true
    elseif rtype == "ammo" then
        local amt = math.max(tonumber(reward.amount) or 0, 0)
        if amt <= 0 or not reward.ammoType then return false end
        ply:GiveAmmo(amt, reward.ammoType, true)
        return true
    elseif rtype == "weapon" then
        if not reward.class then return false end
        ply:Give(reward.class)
        return true
    elseif rtype == "lootpool" then
        local pool = DRR.LootPools[reward.pool or ""]
        local picked = DRR.Util.WeightedPick(pool)
        if not picked then return false end
        return DRR.ApplyReward(ply, picked, multipliers, meta)
    elseif rtype == "streak_protection" then
        local d = DRR.GetPlayerData(ply)
        d.streakProtectionTokens = (tonumber(d.streakProtectionTokens) or 0) + math.max(tonumber(reward.amount) or 1, 1)
        return true
    else
        return hook.Run("DRR_CustomReward", ply, reward, multipliers, meta) == true
    end
end

function DRR.PerformSpin(ply, ignoreLimit)
    local d = DRR.GetPlayerData(ply)
    DRR.DailyResetIfNeeded(ply)

    local allowed = DRR.GetAllowedSpinsToday(ply, d)
    if not ignoreLimit and d.spinsClaimedToday >= allowed then
        net.Start("DR_Toast") net.WriteString("No spins available.") net.Send(ply)
        return false
    end

    local picked, idx = DRR.Util.WeightedPick(DRR.SpinPool)
    if not picked then return false end

    local rewardMeta = {source = "daily_spin"}
    local ok = DRR.ApplyReward(ply, picked.reward, DRR.GetRewardMultipliers(ply, d), rewardMeta)
    if not ok then
        net.Start("DR_Toast") net.WriteString("Reward failed to apply.") net.Send(ply)
        return false
    end

    d.spinsClaimedToday = d.spinsClaimedToday + 1
    d.analytics.totalSpins = (tonumber(d.analytics.totalSpins) or 0) + 1
    d.analytics.totalMoneyGiven = (tonumber(d.analytics.totalMoneyGiven) or 0) + (rewardMeta.moneyAdded or 0)
    DRR.Analytics.RecordSpin(ply, picked, rewardMeta)
    DRR.Storage.SaveSoon(ply:SteamID64())

    net.Start("DR_SpinResult")
        net.WriteUInt(idx, 8)
        net.WriteString(picked.label or "Reward")
        net.WriteString(picked.rarity or "common")
        net.WriteString(picked.icon or "")
        net.WriteFloat(DRR.Config.WheelSpinDuration)
        net.WriteUInt(DRR.Config.WheelFullRotations, 8)
        net.WriteFloat(DRR.Config.WheelStartAngle)
    net.Send(ply)

    DRR.SendSnapshot(ply)
    DRR.Log(string.format("Spin: %s (%s) won %s [%s]", ply:Nick(), ply:SteamID64(), picked.label or "reward", picked.rarity or "common"))
    return true
end

net.Receive("DR_RequestSpin", function(_, ply)
    if not DRR.CanUseNet(ply, "spin") then return end
    DRR.PerformSpin(ply, false)
end)
