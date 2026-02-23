DRR = DRR or {}
DRR.Config = DRR.Config or {}

local C = DRR.Config

C.ResetMode = "utc_midnight"
C.AutoOpenOnJoinIfSpin = true
C.DailyBaseSpins = 1
C.VIPGroups = {"vip", "vip+", "supervip"}
C.VIPBonusSpins = 1
C.VIPMoneyMultiplier = 1.1

C.PlaytimeTickSeconds = 60
C.PlaytimeSpinThresholdsMinutes = {60, 120}
C.AFKDetectionEnabled = false

C.WeeklyRequiredDays = 5
C.GraceDaysAllowed = 1
C.PrestigeStreakRequirement = 30
C.PrestigeMoneyBonusPerLevel = 0.02
C.PrestigeMoneyBonusMax = 0.50

C.StreakMoneyMultiplierTiers = {
    {min = 0, mult = 1.0},
    {min = 7, mult = 1.03},
    {min = 14, mult = 1.06},
    {min = 30, mult = 1.10}
}

C.AdminAccess = function(ply)
    return IsValid(ply) and ply:IsSuperAdmin()
end

C.AllowUnsafeCommands = false
C.LogToFile = false
C.MoneyScale = 1.0

C.WheelSpinDuration = 5.5
C.WheelFullRotations = 6
C.WheelStartAngle = 0
