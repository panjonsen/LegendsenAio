local function Pan_GetBuff(t, bufftype)
    for i, v in t.buffManager.buffs:pairs() do
        if v.isValid and v.type == bufftype then
            return true
        end
    end
end

local function Pan_Aoe(spellObj)
    local count = 0
    for _, entity in ObjectManager.enemyHeroes:pairs() do
        if entity.isEnemy == true then
            if entity and entity:IsValidTarget(spellObj.range) then
                local QPos = spellObj:GetPrediction(entity);
                if QPos then
                    for i, v in QPos:pairs() do

                    end
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function Pan_AutoWhp(W)
    local heroTarget = nil

    for _, entity in ObjectManager.allyHeroes:pairs() do
        if entity.isEnemy == false then
            if Game.localPlayer.position:Distance(entity.position) < W.range then

                local hp = entity.totalHealth
                local hp_max = entity.totalMaxHealth
                --当前血量百分比
                local hp_bfb = hp / hp_max * 100
                --自动加血开关
                local hpW_state = menu.W.hpW[entity.charName].value
                --自动加血阈值百分比
                local hpW_slide = menu.W.hpW[entity.charName .. 'slider'].value
                --自动加血优先级 当前的
                local hpW_priority = menu.W.hpW[entity.charName .. 'priority'].value

                if hp_bfb <= hpW_slide and hpW_state then
                    if heroTarget == nil then
                        heroTarget = entity
                    elseif hpW_priority > menu.W.hpW[heroTarget.charName .. 'priority'].value then
                        heroTarget = entity
                    end
                end

            end
        end

    end

    return heroTarget


end

return function()
    local Q = Champions.Q;
    local W = Champions.W;
    local E = Champions.E;

    --打印英雄英文名称
    print(Game.localPlayer.charName)
    --打印英雄中文名称
    print(Game.localPlayer.displayName)

    local function ontick ()
        Renderer.DrawCircle3D(Game.localPlayer.position,250,1,
              20,
                4290170111
        );


        if menu.W.autohpW.value and  W:Ready() then
            if Pan_AutoWhp(W) then
                W:Cast(Pan_AutoWhp(W))
            end
        end

        --检查连招模式
	
        if Champions.Combo then

            --  Q冷却是好的
            if Q:Ready() then
                --自动Q打开

                if menu.Q.autoQ.value then
                    local t = TargetSelector.GetTarget(Q.range, DamageType.Magical);

                    --local AoeCount = Pan_Aoe(Q)
                    if t and t:IsValidTarget(Q.range) then
                        local QPos = Q:GetPrediction(t);
                        --for k, v in pairs(getmetatable(QPos)) do
                        --    print(k, type(v))
                        --end
                        --print('-----------------')
                        if QPos and menu.Q.slowQ.value then
                            local buffIsValid = Pan_GetBuff(t, BuffType.Slow)
                            if buffIsValid then
                                Q:Cast(QPos.castPosition)
                            end
                        end
                        --禁锢Q
                        if QPos and menu.Q.stunQ.value then
                            if Pan_GetBuff(t, BuffType.Stun) or
                                    Pan_GetBuff(t, BuffType.Taunt) or
                                    Pan_GetBuff(t, BuffType.Shred) or
                                    Pan_GetBuff(t, BuffType.Knockup) or
                                    Pan_GetBuff(t, BuffType.Asleep) or
                                    Pan_GetBuff(t, BuffType.Charm) then

                                Q:Cast(t)
                            end

                        end
                        --正常Q
                        if QPos and not menu.Q.stunQ.value and not menu.Q.slowQ.value and QPos.hitchance  >=HitChance.High then
                            Q:Cast(QPos.castPosition)
                        end
                    end
                end
            end

            if W:Ready() then

			
                if menu.W.autoW.value then
                    --敌人-》我方
                    if menu.W.modeW.value == 1 then
                        --遍历敌人
                        for _, target in ObjectManager.enemyHeroes:pairs() do
                            if target.isEnemy == true then
                                --检查敌人在我W的范围
                                if Game.localPlayer.position:Distance(target.position) < W.range then
                                    --遍历友军
                                    for _, entity in ObjectManager.allyHeroes:pairs() do
                                        if entity.isEnemy == false then
                                            --检查 友军在不在 敌人的范围

                                            if target.position:Distance(entity.position) <= 650 and menu.W.blockW[entity.charName].value and target.isAlive and entity.isAlive then
                                                W:Cast(target)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    ---我方->敌方
                    if menu.W.modeW.value == 2 then
					  
                        --遍历敌人
                        for _, entity in ObjectManager.allyHeroes:pairs() do
                            if entity.isEnemy == false then
							
                                --检查敌人在我W的范围
                                if Game.localPlayer.position:Distance(entity.position) < W.range then
								 
                                    --遍历友军
                                    for _, target in ObjectManager.enemyHeroes:pairs() do
									
                                        if target.isEnemy == true and target.isHero then
										
                                            --检查 敌人在不在 友人的范围
                                   --     print(entity.position:Distance(target.position) ,target.isVisible)
                                            if entity.position:Distance(target.position) <= 650 and menu.W.blockW[entity.charName].value and target.isAlive and entity.isAlive then
                                                --print('触发 W  我方->敌方', entity.charName, target.charName, target.isZombie, entity.isZombie)

                                                W:Cast(entity)

                                            end
                                        end
                                    end

                                end
                            end
                        end
                    end
                end
            end
        end

        --        if target.isEnemy == true and target.isHero then
        --            for i, v in target.buffManager.buffs:pairs() do
        --                if v.isValid then
        --                    print(v:GetName(),entity.charName)
        --                end
        --            end
        --        end
        --    end

    end
    Callback.Bind(CallbackType.OnTick, ontick)


    --新路径回调 可用于皇子EQ
    Callback.Bind(CallbackType.OnNewPath, function(sender, isDash, dashSpeed, path)
        if isDash and Q:Ready() and menu.Q.dashQ.value and sender.isHero and sender.isEnemy and not menu.Q.gapList[sender.charName] then
            local startPos = path[1]
            local endPos = path[2]
            if startPos and endPos then

                if Game.localPlayer.position:Distance(endPos) <= Q.range and menu.Q.dashQlist[sender.charName].value then
                    local castendPos
                    startPos:RelativePos(endPos, startPos:Distance(endPos) + 50)
                    print('触发 isDash', sender.displayName)
                    Q:Cast(endPos)
                end
            end
        end
    end)

    --
    --Callback.Bind(CallbackType.OnSpellCastComplete,function(sender,cast)
    --
    --    if sender.isHero then
    --        print(sender.attackCastDelay,sender.buffManager.owner.charName,cast.isAutoAttack,cast.wasCast,sender:GetTarget())
    --    end
    --
    --end)

    Callback.Bind(CallbackType.OnSpellCastComplete, function(entity, castargs)
        if entity.isHero and entity.isEnemy == false then
            if castargs.target and castargs.target.isHero then
                local Pan_spell_name = castargs.spell:GetName()
                --     print(entity.charName, '触发了平A', Pan_spell_name)

                if Pan_spell_name:find("Attack") and
                        menu.E.autoE.value and
                        menu.E.blockE[entity.charName].value and
                        Game.localPlayer.position:Distance(entity.position) <= E.range
                then
                    E:Cast(entity)
                end
            end
            --for k, v in pairs(getmetatable(entity)) do
            --    print(k, type(v))
            --end

            -- or maybe this will work, not sure:
            --for k, v in castargs:pairs() do
            --    print(k, type(v))
            --end

        end

    end)




    --施法技能回调 开始 用作技能落脚点预测
    Callback.Bind(CallbackType.OnSpellAnimationStart, function(entity, castargs)
	
        if  entity.isHero == true then

    print(entity.spellBook:GetSpellEntry(castargs.slot):DisplayRange())
            print(entity.spellBook:GetSpellEntry(castargs.slot).internalState)

        end


        --print(castargs.spell:GetDamage(Game.localPlayer,))
        --for k, v in pairs(getmetatable(castargs.target)) do
        --    print(k, type(v))
        --end
        if entity.isEnemy == true and entity.isHero == true and menu.Q.gapQ.value then
            if menu.Q.gapList[entity.charName] and menu.Q.gapList[entity.charName]["slot" .. castargs.slot] then
                --技能处理模式 isGap=终点位置  isInt=起点位置   isDash 不在此处回调
                local Pan_type = GapSpell[entity.charName][castargs.slot].mode
                if  Pan_type == "isInt"  or  Pan_type == "isGap"  then
                    local Pan_spell_range = entity.spellBook:GetSpellEntry(castargs.slot):DisplayRange()
                    local Pan_spell_extrDistance = menu.Q.gapList[entity.charName]["extrDistance" .. castargs.slot].value
                    local QPos = Q:GetPrediction(entity);
                    if QPos then
                        local pos = nil

                        if Pan_type == "isGap" then
                            if castargs.from:Distance(castargs.to) > Pan_spell_range then
                                pos = castargs.from:RelativePos(castargs.to, Pan_spell_range + Pan_spell_extrDistance)
                            else
                                pos = castargs.to
                            end

                        elseif Pan_type == "isInt" then

                            pos = castargs.from

                        end
                        --print(Game.localPlayer.position:Distance(castargs.to), "原来的距离")
                        --print(Game.localPlayer.position:Distance(pos), "更改后的距离")
                        if Game.localPlayer.position:Distance(pos) <= Q.range then
                            Q:Cast(pos)
                        end
                    end
                end

                --剑圣特殊判断
                if Pan_type=='MasterYi'  and castargs.target and castargs.target.isMinion  then



                end

            end
        end


    end)


end