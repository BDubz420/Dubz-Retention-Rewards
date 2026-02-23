DRR = DRR or {}

local function dayNum(dateKey)
    local y, m, d = string.match(dateKey or "", "(%d+)%-(%d+)%-(%d+)")
    if not y then return os.time() end
    return os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0})
end

function DRR.ProcessLogin(ply)
    local d = DRR.GetPlayerData(ply)
    local today = DRR.Util.GetUTCDateKey()
    local week = DRR.Util.GetUTCWeekKey()

    if d.weekly.weekKey ~= week then
        d.weekly.weekKey = week
        d.weekly.daysLogged = {}
        d.weekly.weeklyClaimed = false
        d.graceUsedThisWeek = 0
    end

    if d.lastLoginDate ~= today then
        local diffDays = math.floor((dayNum(today) - dayNum(d.lastLoginDate)) / 86400)
        if d.lastLoginDate == "" or diffDays <= 1 then
            d.streak = math.max(tonumber(d.streak) or 0, 0) + 1
        elseif diffDays == 2 and d.graceUsedThisWeek < DRR.Config.GraceDaysAllowed then
            d.graceUsedThisWeek = d.graceUsedThisWeek + 1
            d.streak = math.max(tonumber(d.streak) or 0, 0) + 1
        elseif (tonumber(d.streakProtectionTokens) or 0) > 0 then
            d.streakProtectionTokens = d.streakProtectionTokens - 1
            d.streak = math.max(tonumber(d.streak) or 0, 0) + 1
        else
            d.streak = 1
        end

        d.weekly.daysLogged[today] = true
        d.lastLoginDate = today
        DRR.DailyResetIfNeeded(ply)
        DRR.HandlePrestige(ply)
        DRR.Storage.SaveSoon(ply:SteamID64())
    end
end

function DRR.AdminResetStreak(sid)
    local d = DRR.Storage.Load(sid)
    d.streak = 0
    d.graceUsedThisWeek = 0
    d.streakProtectionTokens = 0
    DRR.Storage.SaveSoon(sid)
end
