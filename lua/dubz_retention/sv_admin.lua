DRR = DRR or {}

concommand.Add("drr_admin", function(ply)
    if not IsValid(ply) or not DRR.Config.AdminAccess(ply) then return end
    net.Start("DR_AdminCmd") net.WriteString("open") net.Send(ply)
end)

net.Receive("DR_AdminCmd", function(_, ply)
    if not DRR.CanUseNet(ply, "admin") then return end

    local action = net.ReadString()
    if action == "claim_weekly" then
        DRR.ClaimWeekly(ply)
        return
    end

    if not DRR.Config.AdminAccess(ply) then return end

    if action == "get_stats" then
        net.Start("DR_AdminCmd")
            net.WriteString("stats")
            net.WriteTable(DRR.Analytics.GetAdminStats())
        net.Send(ply)
    elseif action == "reset_streak" then
        DRR.AdminResetStreak(net.ReadString())
    elseif action == "grant_token" then
        local sid = net.ReadString()
        local amount = math.Clamp(net.ReadUInt(8), 1, 25)
        local d = DRR.Storage.Load(sid)
        d.streakProtectionTokens = (tonumber(d.streakProtectionTokens) or 0) + amount
        DRR.Storage.SaveSoon(sid)
    elseif action == "force_spin" then
        local sid = net.ReadString()
        for _, t in ipairs(player.GetHumans()) do
            if t:SteamID64() == sid then
                DRR.PerformSpin(t, true)
                break
            end
        end
    end
end)
