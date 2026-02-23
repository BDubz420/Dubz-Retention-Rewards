DRR = DRR or {}
DRR.LootPools = DRR.LootPools or {}

DRR.LootPools.daily_crate = {
    {id = "money_small", type = "money", amount = 250, rarity = "common", weight = 35},
    {id = "ammo_pack", type = "ammo", ammoType = "Pistol", amount = 24, rarity = "common", weight = 30},
    {id = "money_med", type = "money", amount = 500, rarity = "uncommon", weight = 18},
    {id = "token", type = "streak_protection", amount = 1, rarity = "rare", weight = 8},
    {id = "weapon", type = "weapon", class = "weapon_pistol", rarity = "epic", weight = 6},
    {id = "money_big", type = "money", amount = 1400, rarity = "legendary", weight = 3}
}

DRR.LootPools.weekly_crate = {
    {id = "weekly_money", type = "money", amount = 2200, rarity = "uncommon", weight = 40},
    {id = "weekly_ammo", type = "ammo", ammoType = "SMG1", amount = 80, rarity = "rare", weight = 30},
    {id = "weekly_token", type = "streak_protection", amount = 2, rarity = "epic", weight = 20},
    {id = "weekly_weapon", type = "weapon", class = "weapon_shotgun", rarity = "legendary", weight = 8},
    {id = "weekly_jackpot", type = "money", amount = 6000, rarity = "jackpot", weight = 2}
}
