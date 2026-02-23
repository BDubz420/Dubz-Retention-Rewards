DRR = DRR or {}
DRR.Storage = DRR.Storage or {}

file.CreateDir(DRR.Const.DataDir)

DRR.Storage.Cache = DRR.Storage.Cache or {}
DRR.Storage.Pending = DRR.Storage.Pending or {}

local function defaultData(sid)
    return {
        steamid64 = sid,
        lastLoginDate = "",
        lastSpinDate = "",
        spinsClaimedToday = 0,
        extraSpinsToday = 0,
        streak = 0,
        graceUsedThisWeek = 0,
        streakProtectionTokens = 0,
        prestige = 0,
        playtimeTodaySeconds = 0,
        playtimeRewardedTiers = {},
        weekly = {weekKey = DRR.Util.GetUTCWeekKey(), daysLogged = {}, weeklyClaimed = false},
        analytics = {totalSpins = 0, totalMoneyGiven = 0, spinsTodayCounted = 0}
    }
end

function DRR.Storage.DefaultData(sid) return defaultData(sid) end

local function pathFor(sid)
    return string.format("%s/%s.json", DRR.Const.DataDir, sid)
end

local function sanitize(tbl, sid)
    local d = defaultData(sid)
    tbl = istable(tbl) and tbl or {}
    for k, v in pairs(d) do
        if tbl[k] == nil then tbl[k] = v end
    end
    tbl.weekly = istable(tbl.weekly) and tbl.weekly or d.weekly
    tbl.weekly.daysLogged = istable(tbl.weekly.daysLogged) and tbl.weekly.daysLogged or {}
    tbl.playtimeRewardedTiers = istable(tbl.playtimeRewardedTiers) and tbl.playtimeRewardedTiers or {}
    tbl.analytics = istable(tbl.analytics) and tbl.analytics or d.analytics
    return tbl
end

function DRR.Storage.Load(sid)
    if DRR.Storage.Cache[sid] then return DRR.Storage.Cache[sid] end
    local p = pathFor(sid)
    local data
    if file.Exists(p, "DATA") then
        data = util.JSONToTable(file.Read(p, "DATA") or "")
    end
    data = sanitize(data, sid)
    DRR.Storage.Cache[sid] = data
    return data
end

local function flushSid(sid)
    local t = DRR.Storage.Cache[sid]
    if not t then return end
    file.Write(pathFor(sid), util.TableToJSON(t, true))
    DRR.Storage.Pending[sid] = nil
end

function DRR.Storage.SaveSoon(sid)
    if DRR.Storage.Pending[sid] then return end
    DRR.Storage.Pending[sid] = true
    timer.Simple(DRR.Const.SaveDebounce, function() flushSid(sid) end)
end

function DRR.Storage.FlushAll()
    for sid, _ in pairs(DRR.Storage.Cache) do flushSid(sid) end
end

hook.Add("ShutDown", "DRR_FlushOnShutdown", DRR.Storage.FlushAll)
