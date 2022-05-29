--extrDistance =额外施法距离 比如EZ的E 在E终点位置上在往前X距离
--isGap ==防突进
--isInt ==中断
--isDash == 突进状态
GapSpell = {

 
  
    ['Malzahar'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" }
    },
    ['Ezreal'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" },
        [2] = { slotName = 'E', slot = 2, extrDistance = 0, mode = "isGap" }
    },
    ['Janna'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" }
    },
    ['Seraphine'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" }
    },
    ['Velkoz'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" }
    },
    ['Sion'] = {
        [0] = { slotName = 'Q', slot = 0, extrDistance = 0, mode = "isInt" }
    },
    ['Jinx'] = {
        [1] = { slotName = 'W', slot = 1, extrDistance = 0, mode = "isInt" }
    },
    ['Neeko'] = {
        [3] = { slotName = 'R', slot = 3, extrDistance = 0, mode = "isInt" }
    },
    ['Thresh'] = {
        [0] = { slotName = 'Q', slot = 0, extrDistance = 0, mode = "isInt" }
    },
  
 
   
   
--
--,
--    ['LeeSin'] = {
--        [2] = { slotName = 'W', slot = 0, extrDistance = 50, mode = "isInt" }
--    }

    --
    --['Yasuo'] = {
    --    [2] = { slotName = 'E', slot = 2, extrDistance = 230, mode = "isGap" }
    --},
    --['Lillia'] = {
    --    [1] = { slotName = "W", slot = 1, extrDistance = 100, mode = "isGap" }
    --},
    --['Jax'] = {--非指向性技能
    --    [0] = { slotName = "Q突进", slot = 0, extrDistance = 0, mode = "isGap" }
    --},
    --['Yone'] = {
    --    [3] = { slotName = 'R突进', slot = 3, extrDistance = 50, mode = "isGap" }
    --},
    --['Pyke'] = {
    --    [2] = { slotName = 'E突进', slot = 2, extrDistance = 100, mode = "isGap" }
    --},
    --['TahmKench'] = {
    --    [1] = { slotName = 'W突进', slot = 1, extrDistance = 0, mode = "isGap" }
    --}
}

local charName = Game.localPlayer.charName;
local displayName = Game.localPlayer.displayName;

--print(MODULE_NAME);
--create root menu
local menu = UI.Menu.CreateMenu(charName, displayName, 2);

--create base menu , we should clear later when unload.
Champions.CreateBaseMenu(menu, 0);

local QMenu = menu:AddMenu("Q", "Q");
local rangeQ = QMenu:AddSlider("rangeQ", "Q范围设置", 875, 100, 875, 10, function(s)
    Champions.Q = (SDKSpell.Create(SpellSlot.Q, menu.Q.rangeQ.value, DamageType.Magical))
end);
local hitchanceQ=QMenu:AddList(("hitchanceQ"), ("QHitchance"), { ("Medium"), (("High")), (("VeryHigh(Slow)")) }, 1);
local autoQ = QMenu:AddCheckBox(("autoQ"), ("Auto Q"));
local slowQ = QMenu:AddCheckBox(("slowQ"), ("减速 Q"));
local stunQ = QMenu:AddCheckBox(("stunQ"), ("禁锢 Q"));
local dashQ = QMenu:AddCheckBox(("dashQ"), ("自动防突进(禁锢)Q"));
local dashQlist = QMenu:AddMenu(("dashQlist"), ("自动防突进列表"));
for _, entity in ObjectManager.enemyHeroes:pairs() do
    if entity.isEnemy == true  and  not GapSpell[entity.charName]  then
        dashQlist:AddCheckBox(entity.charName, entity.displayName );
    end
end

local gapQ = QMenu:AddCheckBox(("gapQ"), ("技能中断 Q"));
local gapList = QMenu:AddMenu("gapList", "技能中断列表(好比你的落脚点是50那么你设置额外距离是60那么落点=110)");
for _, entity in ObjectManager.enemyHeroes:pairs() do
    if entity.isEnemy == true then
        if GapSpell[entity.charName] then
            local gapListCharName = gapList:AddMenu(entity.charName, entity.displayName);
            for _, v in pairs(GapSpell[entity.charName]) do
                gapListCharName:AddCheckBox("slot" .. v.slot, entity.displayName .. "  " .. v.slotName);
                gapListCharName:AddSlider("extrDistance" .. v.slot, "额外距离", v.extrDistance, 1, 300, 1)
            end
        end
    end
end

local WMenu = menu:AddMenu("W", "W");
local autoW = WMenu:AddCheckBox(("autoW"), ("Auto W"));
WMenu:AddInfo("_h", "---------------连招模式---------------")
local modeW = WMenu:AddList(("modeW"), ("连招模式"), { ("不使用"), (("敌方->我方")), (("我方->敌方")) }, 1);
local blockW = WMenu:AddMenu("blockW", "连招W白名单");
for _, entity in ObjectManager.allyHeroes:pairs() do
    if entity.isEnemy == false then
        blockW:AddCheckBox(entity.charName, entity.displayName .. "开关");
    end
end

WMenu:AddInfo("_h", "---------------自动加血---------------")

local autohpW = WMenu:AddCheckBox(("autohpW"), ("自动加血W"));
local hpW = WMenu:AddMenu("hpW", "自动W加血设置");
--W遍历队友 自动加血百分比
for _, entity in ObjectManager.allyHeroes:pairs() do
    if entity.isEnemy == false then
        hpW:AddCheckBox(entity.charName, entity.displayName .. "开关");
        hpW:AddSlider(entity.charName .. 'priority', entity.displayName .. "  优先级", 1, 1, 5, 1)
        hpW:AddSlider(entity.charName .. 'slider', entity.displayName .. "  血量百分比", 20, 0, 100, 1)
        hpW:AddInfo("_h", "---------------" .. entity.displayName .. "---------------")
    end
end

local EMenu = menu:AddMenu("E", "E");
local autoE = EMenu:AddCheckBox(("autoE"), ("Auto E"));
local blockE = EMenu:AddMenu("blockE", "E白名单");
--E遍历队友 自动加E
for _, entity in ObjectManager.allyHeroes:pairs() do
    if entity.isEnemy == false then
        blockE:AddCheckBox(entity.charName, entity.charName .. "开关");
    end
end

local RMenu = menu:AddMenu("R", "R");
local autoR = RMenu:AddCheckBox(("autoR"), ("暂时无效,没有找到AOE命令"));

local draw = menu:AddMenu(("draw"), ("Drawing"));
Champions.Q = (SDKSpell.Create(SpellSlot.Q, menu.Q.rangeQ.value, DamageType.Magical))
Champions.W = (SDKSpell.Create(SpellSlot.W, 725, DamageType.Magical))
Champions.E = (SDKSpell.Create(SpellSlot.E, 800, DamageType.Magical))
Champions.R = (SDKSpell.Create(SpellSlot.R, 1000, DamageType.Magical))
Champions.CreateColorMenu(draw, true)

return menu



