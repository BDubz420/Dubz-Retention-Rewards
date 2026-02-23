if SERVER then
    AddCSLuaFile("dubz_retention/sh_constants.lua")
    AddCSLuaFile("dubz_retention/sh_config.lua")
    AddCSLuaFile("dubz_retention/sh_util.lua")
    AddCSLuaFile("dubz_retention/sh_rewards.lua")
    AddCSLuaFile("dubz_retention/sh_lootpools.lua")

    AddCSLuaFile("dubz_retention/cl_fonts.lua")
    AddCSLuaFile("dubz_retention/cl_ui_effects.lua")
    AddCSLuaFile("dubz_retention/cl_ui_spin.lua")
    AddCSLuaFile("dubz_retention/cl_ui_main.lua")
    AddCSLuaFile("dubz_retention/cl_ui_admin.lua")
end

include("dubz_retention/sh_constants.lua")
include("dubz_retention/sh_config.lua")
include("dubz_retention/sh_util.lua")
include("dubz_retention/sh_rewards.lua")
include("dubz_retention/sh_lootpools.lua")

if SERVER then
    include("dubz_retention/sv_storage.lua")
    include("dubz_retention/sv_analytics.lua")
    include("dubz_retention/sv_core.lua")
    include("dubz_retention/sv_streak.lua")
    include("dubz_retention/sv_playtime.lua")
    include("dubz_retention/sv_weekly.lua")
    include("dubz_retention/sv_prestige.lua")
    include("dubz_retention/sv_spin.lua")
    include("dubz_retention/sv_admin.lua")
else
    include("dubz_retention/cl_fonts.lua")
    include("dubz_retention/cl_ui_effects.lua")
    include("dubz_retention/cl_ui_spin.lua")
    include("dubz_retention/cl_ui_main.lua")
    include("dubz_retention/cl_ui_admin.lua")
end
