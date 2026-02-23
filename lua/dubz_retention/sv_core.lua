DRR = DRR or {}
DRR.Net = DRR.Net or {}

util.AddNetworkString("DR_OpenMenu")
util.AddNetworkString("DR_RequestSpin")
util.AddNetworkString("DR_SpinResult")
util.AddNetworkString("DR_DataSnapshot")
util.AddNetworkString("DR_Toast")
util.AddNetworkString("DR_AdminCmd")

DRR.Net.Rate = DRR.Net.Rate or {}

function DRR.GetPlayerData(ply)
    return DRR.Storage.Load(ply:SteamID64())
end

function DRR.Log(msg)
    MsgC(Color(80, 170, 255), "[DubzRetention] ", color_white, tostring(msg) .. "\n")
    if DRR.Config.LogToFile then
        file.Append(DRR.Const.DataDir .. "/events.log", os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(msg) .. "\n")
    end
end

function DRR.CanUseNet(ply, key)
    local sid = ply:SteamID64()
    local k = sid .. ":" .. key
    local now = CurTime()
    local s = DRR.Net.Rate[k] or {last = 0, minuteStamp = now, minuteCount = 0}
    if now - s.minuteStamp > 60 then s.minuteStamp = now s.minuteCount = 0 end

    if now - s.last < DRR.Const.NetRateLimitSeconds or s.minuteCount >= DRR.Const.NetMaxPerMinute then
        DRR.Log("Rate-limit triggered for " .. ply:Nick() .. " on " .. key)
        DRR.Net.Rate[k] = s
        return false
    end

    s.last = now
    s.minuteCount = s.minuteCount + 1
    DRR.Net.Rate[k] = s
    return true
end

function DRR.GetAllowedSpinsToday(ply, data)
    local total = DRR.Config.DailyBaseSpins + (tonumber(data.extraSpinsToday) or 0)
    if DRR.Util.HasVIP(ply) then total = total + DRR.Config.VIPBonusSpins end
    return math.max(total, 0)
end

function DRR.BuildSnapshot(ply)
    local d = DRR.GetPlayerData(ply)
    return {
        streak = d.streak,
        prestige = d.prestige,
        tokens = d.streakProtectionTokens,
        spinsClaimedToday = d.spinsClaimedToday,
        allowedSpinsToday = DRR.GetAllowedSpinsToday(ply, d),
        playtimeTodaySeconds = d.playtimeTodaySeconds,
        playtimeRewardedTiers = d.playtimeRewardedTiers,
        weekly = d.weekly,
        graceUsedThisWeek = d.graceUsedThisWeek
    }
end

function DRR.SendSnapshot(ply)
    net.Start("DR_DataSnapshot")
        net.WriteTable(DRR.BuildSnapshot(ply))
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "DRR_InitPlayer", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        DRR.ProcessLogin(ply)
        DRR.SendSnapshot(ply)
        if DRR.Config.AutoOpenOnJoinIfSpin then
            local d = DRR.GetPlayerData(ply)
            if d.spinsClaimedToday < DRR.GetAllowedSpinsToday(ply, d) then
                net.Start("DR_OpenMenu")
                net.Send(ply)
            end
        end
    end)
end)

concommand.Add("drr_open", function(ply)
    if IsValid(ply) then
        DRR.SendSnapshot(ply)
        net.Start("DR_OpenMenu")
        net.Send(ply)
    end
end)

hook.Add("PlayerSay", "DRR_ChatCommands", function(ply, txt)
    txt = string.lower(string.Trim(txt or ""))
    if txt == "/daily" or txt == "/spin" then
        DRR.SendSnapshot(ply)
        net.Start("DR_OpenMenu")
        net.Send(ply)
        return ""
    end
    if txt == "/dailyadmin" and DRR.Config.AdminAccess(ply) then
        net.Start("DR_AdminCmd") net.WriteString("open") net.Send(ply)
        return ""
    end
end)
