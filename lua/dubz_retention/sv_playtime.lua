DRR = DRR or {}

timer.Create("DRR_PlaytimeTick", DRR.Config.PlaytimeTickSeconds, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        local d = DRR.GetPlayerData(ply)
        d.playtimeTodaySeconds = (tonumber(d.playtimeTodaySeconds) or 0) + DRR.Config.PlaytimeTickSeconds

        for idx, mins in ipairs(DRR.Config.PlaytimeSpinThresholdsMinutes or {}) do
            if not d.playtimeRewardedTiers[idx] and d.playtimeTodaySeconds >= mins * 60 then
                d.playtimeRewardedTiers[idx] = true
                d.extraSpinsToday = (tonumber(d.extraSpinsToday) or 0) + 1
                net.Start("DR_Toast")
                    net.WriteString("Playtime bonus spin unlocked: " .. mins .. " minutes")
                net.Send(ply)
            end
        end

        DRR.Storage.SaveSoon(ply:SteamID64())
    end
end)
