DRR = DRR or {}
DRR.Util = DRR.Util or {}

function DRR.Util.GetUTCDateKey(ts)
    return os.date("!%Y-%m-%d", ts or os.time())
end

function DRR.Util.GetUTCWeekKey(ts)
    return os.date("!%G-W%V", ts or os.time())
end

function DRR.Util.TableCopy(t)
    return util.JSONToTable(util.TableToJSON(t or {}, false)) or {}
end

function DRR.Util.WeightedPick(list)
    if not istable(list) or #list == 0 then return nil, nil end
    local total = 0
    for _, v in ipairs(list) do total = total + math.max(tonumber(v.weight) or 0, 0) end
    if total <= 0 then return nil, nil end

    local roll = math.Rand(0, total)
    local running = 0
    for idx, v in ipairs(list) do
        running = running + math.max(tonumber(v.weight) or 0, 0)
        if roll <= running then
            return v, idx
        end
    end
    return list[#list], #list
end

function DRR.Util.GetRarityColor(rarity)
    local c = DRR.Const.Color[rarity or "common"]
    return c or DRR.Const.Color.common
end

function DRR.Util.HasVIP(ply)
    if not IsValid(ply) then return false end
    local ug = string.lower(ply:GetUserGroup() or "")
    for _, g in ipairs(DRR.Config.VIPGroups or {}) do
        if ug == string.lower(g) then return true end
    end
    return false
end
