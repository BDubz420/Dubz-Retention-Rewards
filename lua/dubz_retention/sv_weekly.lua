DRR = DRR or {}

function DRR.CanClaimWeekly(ply)
    local d = DRR.GetPlayerData(ply)
    local count = table.Count(d.weekly.daysLogged or {})
    return count >= DRR.Config.WeeklyRequiredDays and not d.weekly.weeklyClaimed
end

function DRR.ClaimWeekly(ply)
    local d = DRR.GetPlayerData(ply)
    if not DRR.CanClaimWeekly(ply) then return false, "Not eligible yet" end
    local reward = {type = "lootpool", pool = "weekly_crate"}
    local ok = DRR.ApplyReward(ply, reward, DRR.GetRewardMultipliers(ply, d), {source = "weekly"})
    if ok then
        d.weekly.weeklyClaimed = true
        DRR.Storage.SaveSoon(ply:SteamID64())
        DRR.SendSnapshot(ply)
        return true
    end
    return false, "Failed"
end
