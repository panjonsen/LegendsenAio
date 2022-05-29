--打印英雄英文名称
print(Game.localPlayer.charName)
--打印英雄中文名称
print(Game.localPlayer.displayName)



if Game.localPlayer.charName ~= "Nami" then
return
end



--disable cpp champion script if need
Champions.CppScriptMaster(false)

-- Menu:
menu = Environment.LoadModule("menu")

local logic = Environment.LoadModule("logic")

local function init()


    ----Manager Spell class pointer so we call use  Champions.Clean() when unload
    --Champions.Q = (SDKSpell.Create(SpellSlot.Q, 860, DamageType.Magical))
    --Champions.W = (SDKSpell.Create(SpellSlot.W, 750, DamageType.Magical))
    --Champions.E = (SDKSpell.Create(SpellSlot.E, 800, DamageType.Magical))
    --Champions.R = (SDKSpell.Create(SpellSlot.R, 1000, DamageType.Magical))
    --
    --
    --
    ----技能延迟 原角度/宽度 技能速度
    ----SkillshotLine=线性
    ----SkillshotCircle=圆形
    ----CollidesWithYasuoWall 亚索风墙碰撞
    ----CollidesWithNothing没有碰撞
    Champions.Q:SetSkillshot(1, 110, math.huge, SkillshotType.SkillshotCircle, true, CollisionFlag.CollidesWithYasuoWall, HitChance.High, true)
    Champions.R:SetSkillshot(0.5, 125, math.huge, SkillshotType.SkillshotLine, true, CollisionFlag.CollidesWithYasuoWall, HitChance.High, true)
    logic();
end

init()

Callback.Bind(CallbackType.OnUnload, function()
    Champions.Clean()--clean QWER Spell pointer , spell range dmobj
end)

--Callback.Bind(CallbackType.OnSpellCast, function(spell)
--
--    print(spell.charName)
--end)

--Callback.Bind(CallbackType.OnChangeSlotSpellName, function(sender,slot,name)
--
--    print(name)
--end)
