local rotationName = "Cpoworks"

---------------
--- Toggles ---
---------------
local function createToggles()
    -- Rotation Button
    RotationModes = {
        [1] = { mode = "Auto", value = 1 , overlay = "Automatic Rotation", tip = "Swaps between Single and Multiple based on number of targets in range.", highlight = 1, icon = br.player.spell.mindFlay },
        [2] = { mode = "Mult", value = 2 , overlay = "Multiple Target Rotation", tip = "Multiple target rotation used.", highlight = 0, icon = br.player.spell.mindFlay },
        [3] = { mode = "Sing", value = 3 , overlay = "Single Target Rotation", tip = "Single target rotation used.", highlight = 0, icon = br.player.spell.mindFlay },
        [4] = { mode = "Off", value = 4 , overlay = "DPS Rotation Disabled", tip = "Disable DPS Rotation", highlight = 0, icon = br.player.spell.shadowMend}
    };
    CreateButton("Rotation",1,0)
    -- Cooldown Button
    CooldownModes = {
        [1] = { mode = "Auto", value = 1 , overlay = "Cooldowns Automated", tip = "Automatic Cooldowns - Boss Detection.", highlight = 1, icon = br.player.spell.mindBlast },
        [2] = { mode = "On", value = 1 , overlay = "Cooldowns Enabled", tip = "Cooldowns used regardless of target.", highlight = 0, icon = br.player.spell.mindBlast },
        [3] = { mode = "Off", value = 3 , overlay = "Cooldowns Disabled", tip = "No Cooldowns will be used.", highlight = 0, icon = br.player.spell.mindBlast }
    };
   	CreateButton("Cooldown",2,0)
    -- Defensive Button
    DefensiveModes = {
        [1] = { mode = "On", value = 1 , overlay = "Defensive Enabled", tip = "Includes Defensive Cooldowns.", highlight = 1, icon = br.player.spell.dispersion },
        [2] = { mode = "Off", value = 2 , overlay = "Defensive Disabled", tip = "No Defensives will be used.", highlight = 0, icon = br.player.spell.dispersion }
    };
    CreateButton("Defensive",3,0)
end

---------------
--- OPTIONS ---
---------------
local function createOptions()
    local optionTable

    local function rotationOptions()
        local section
        -- General Options
        section = br.ui:createSection(br.ui.window.profile, "General")
            -- Mouseover Dotting
            br.ui:createCheckbox(section,"Mouseover Dotting")
            -- SWP Max Targets
            br.ui:createSpinner(section, "SWP Max Targets",  3,  1,  10,  1)
            -- VT Max Targets
            br.ui:createSpinner(section, "VT Max Targets",  3,  1,  10,  1)
        br.ui:checkSectionState(section)
        -- Cooldown Options
        section = br.ui:createSection(br.ui.window.profile, "Cooldowns")
            -- Int Pot
            br.ui:createCheckbox(section,"Int Pot")
            -- Flask / Crystal
            br.ui:createCheckbox(section,"Flask / Crystal")
            -- Trinkets
            br.ui:createCheckbox(section,"Trinkets")
            -- Touch of the Void
            if hasEquiped(128318) then
                br.ui:createCheckbox(section,"Touch of the Void")
            end
            -- Shadowfiend
            br.ui:createCheckbox(section,"Shadowfiend / Mindbender")
            -- Surrender To Madness
            br.ui:createCheckbox(section,"Surrender To Madness")
            -- Power Infusion
            br.ui:createCheckbox(section,"Power Infusion")
        br.ui:checkSectionState(section)
        -- Defensive Options
        section = br.ui:createSection(br.ui.window.profile, "Defensive")
            -- Healthstone
            br.ui:createSpinner(section, "Healthstone",  60,  0,  100,  5,  "|cffFFBB00Health Percentage to use at.")
            -- Gift of The Naaru
            if br.player.race == "Draenei" then
                br.ui:createSpinner(section, "Gift of the Naaru",  50,  0,  100,  5,  "|cffFFFFFFHealth Percent to Cast At")
            end
            -- Power Word: Shield
            br.ui:createSpinner(section, "Power Word: Shield",  60,  0,  100,  5,  "|cffFFBB00Health Percentage to use at.")
            -- Dispel Magic
            br.ui:createCheckbox(section,"Dispel Magic")
        br.ui:checkSectionState(section)
        -- Toggle Key Options
        section = br.ui:createSection(br.ui.window.profile, "Toggle Keys")
            -- Single/Multi Toggle
            br.ui:createDropdown(section, "Rotation Mode", br.dropOptions.Toggle,  4)
            -- Cooldown Key Toggle
            br.ui:createDropdown(section, "Cooldown Mode", br.dropOptions.Toggle,  3)
            -- Pause Toggle
            br.ui:createDropdown(section, "Pause Mode", br.dropOptions.Toggle,  6)
        br.ui:checkSectionState(section)
    end
    optionTable = {{
        [1] = "Rotation Options",
        [2] = rotationOptions,
    }}
    return optionTable
end

----------------
--- ROTATION ---
----------------
local function runRotation()
    if br.timer:useTimer("debugShadow", 0.1) then
        --Print("Running: "..rotationName)

---------------
--- Toggles ---
---------------
        UpdateToggle("Rotation",0.25)
        UpdateToggle("Cooldown",0.25)
        UpdateToggle("Defensive",0.25)
        UpdateToggle("VoidEruption",0.25)
--------------
--- Locals ---
--------------
        local addsExist                                     = false
        local addsIn                                        = 999
        local artifact                                      = br.player.artifact
        local buff                                          = br.player.buff
        local canFlask                                      = canUse(br.player.flask.wod.agilityBig)
        local cast                                          = br.player.cast
        local castable                                      = br.player.cast.debug
        local combatTime                                    = getCombatTime()
        local cd                                            = br.player.cd
        local charges                                       = br.player.charges
        local deadMouse                                     = UnitIsDeadOrGhost("mouseover")
        local deadtar, attacktar, hastar, playertar         = deadtar or UnitIsDeadOrGhost("target"), attacktar or UnitCanAttack("target", "player"), hastar or ObjectExists("target"), UnitIsPlayer("target")
        local debuff                                        = br.player.debuff
        local enemies                                       = enemies or {}
        local falling, swimming, flying, moving             = getFallTime(), IsSwimming(), IsFlying(), GetUnitSpeed("player")>0
        local flaskBuff                                     = getBuffRemain("player",br.player.flask.wod.buff.agilityBig)
        local friendly                                      = friendly or UnitIsFriend("target", "player")
        local gcd                                           = br.player.gcd
        local hasMouse                                      = ObjectExists("mouseover")
        local healPot                                       = getHealthPot()
        local inCombat                                      = br.player.inCombat
        local inInstance                                    = br.player.instance=="party"
        local inRaid                                        = br.player.instance=="raid"
        local lastSpell                                     = lastSpellCast
        local level                                         = br.player.level
        local lootDelay                                     = getOptionValue("LootDelay")
        local lowestHP                                      = br.friend[1].unit
        local mode                                          = br.player.mode
        local moveIn                                        = 999
        -- local multidot                                      = (useCleave() or br.player.mode.rotation ~= 3)
        local perk                                          = br.player.perk
        local php                                           = br.player.health
        local playerMouse                                   = UnitIsPlayer("mouseover")
        local power, powmax, powgen, powerDeficit           = br.player.power.insanity.amount, br.player.power.insanity.max, br.player.power.regen, br.player.power.insanity.deficit
        local pullTimer                                     = br.DBM:getPulltimer()
        local racial                                        = br.player.getRacial()
        local recharge                                      = br.player.recharge
        local solo                                          = br.player.instance=="none"
        local spell                                         = br.player.spell
        local t18_2pc                                       = TierScan("T18")>=2
        local t19_2pc                                       = TierScan("T19")>=2
        local t19_4pc                                       = TierScan("T19")>=4
        local talent                                        = br.player.talent
        local thp                                           = getHP(br.player.units(40))
        local ttd                                           = getTTD
        local ttm                                           = br.player.power.ttm
        local units                                         = units or {}

        local SWPmaxTargets                                 = getOptionValue("SWP Max Targets")
        local VTmaxTargets                                  = getOptionValue("VT Max Targets")

        units.dyn5 = br.player.units(5)
        units.dyn40 = br.player.units(40)
        enemies.yards40 = br.player.enemies(40)

        if useMindBlast == nil then useMindBlast = false end
        if leftCombat == nil then leftCombat = GetTime() end
        if profileStop == nil then profileStop = false end
        if IsHackEnabled("NoKnockback") ~= nil then SetHackEnabled("NoKnockback", false) end
        if t19_2pc then t19pc2 = 1 else t19pc2 = 0 end
        if hasBloodLust() then lusting = 1 else lusting = 0 end
        if talent.sanlayn then sanlayn = 1 else sanlayn = 0 end
        if talent.reaperOfSouls then reaperOfSouls = 1 else reaperOfSouls = 0 end

        -- Insanity Stacks
        local drainStacks = buff.voidForm.stack()
        -- local drainStacks = drainStacks or 0
        -- if not inCombat or not buff.voidForm.exists() then drainStacks = 0 end
        -- C_Timer.After(1, function()
        --     if buff.voidForm.exists() and not (buff.dispersion.exists() or buff.voidTorrent.exists()) then
        --         drainStacks = drainStacks + 1
        --         Print(drainStacks)
        --     end
        -- end)

        -- Mind Flay Ticks
        local mfTick = mfTick or 0
        if not inCombat or not isCastingSpell(spell.mindFlay) then mfTick = 0 end
        if br.timer:useTimer("Mind Flay Ticks", 0.75) and isCastingSpell(spell.mindFlay) then
            mfTick = mfTick + 1
        end

        -- Insanity Drain
        insanityDrain = 6 + (2 / 3) * drainStacks

--------------------
--- Action Lists ---
--------------------
        -- Action list - Extras
        function actionList_Extra()
            -- Dispel Magic
            -- if isChecked("Dispel Magic") and canDispel("target",br.player.spell.dispelMagic) and not isBoss() and ObjectExists("target") then
            --     if cast.dispelMagic() then return end
            -- end
        end -- End Action List - Extra
        -- Action List - Defensive
        function actionList_Defensive()
            if useDefensive() and getHP("player")>0 then
                -- Gift of the Naaru
                if isChecked("Gift of the Naaru") and php <= getOptionValue("Gift of the Naaru") and php > 0 and br.player.race=="Draenei" then
                    if castSpell("player",racial,false,false,false) then return end
                end
                -- Power Word: Shield
                if isChecked("Power Word: Shield") and php <= getOptionValue("Power Word: Shield") and not buff.powerWordShield.exists() then
                    if cast.powerWordShield("player") then return end
                end
            end -- End Defensive Check
        end -- End Action List - Defensive
        -- Action List - Interrupts
        function actionList_Interrupts()

        end -- End Action List - Interrupts
        -- Action List - Cooldowns
        function actionList_Cooldowns()
            if useCDs() then
                -- Racials
                -- blood_fury
                -- arcane_torrent
                -- berserking
                if (br.player.race == "Orc" or br.player.race == "Troll" or br.player.race == "BloodElf") then
                    if br.player.castRacial() then return end
                end
                -- Touch of the Void
                if isChecked("Touch of the Void") and getDistance(br.player.units.dyn5)<5 then
                    if hasEquiped(128318) then
                        if GetItemCooldown(128318)==0 then
                            useItem(128318)
                        end
                    end
                end
                -- Trinkets
                if isChecked("Trinkets") then
                    if canUse(13) then
                        useItem(13)
                    end
                    if canUse(14) then
                        useItem(14)
                    end
                end
            end
        end -- End Action List - Cooldowns
        -- Action List - Pre-Combat
        function actionList_PreCombat()
        -- Shadow Form
            -- shadowform,if=!buff.shadowform.up
            if not buff.shadowform.exists() then
                cast.shadowform()
            end
        -- Variable: s2mBeltCheck
            -- variable,op=set,name=s2mbeltcheck,value=cooldown.mind_blast.charges>=2
            if charges.mindBlast >= 2 then s2mBeltCheck = 1 else s2mBeltCheck = 0 end
        -- Mind Blast
            if isValidUnit("target") then
                if cast.mindBlast("target") then return end
            end
            -- -- Power Word: Shield Body and Soul
            -- if talent.bodyAndSoul and isMoving("player") and not IsMounted() then
            --     if cast.powerWordShield("player") then return end
            -- end
        end  -- End Action List - Pre-Combat
        -- Action List - Check
        function actionList_Check()
            -- variable,op=set,name=s2mbeltcheck,value=cooldown.mind_blast.charges>=2
            if charges.mindBlast >= 2 then s2mBeltCheck = 1 else s2mBeltCheck = 0 end
            -- variable,op=set,name=actors_fight_time_mod,value=0
            actorsFightTimeMod = 0
            -- variable,op=set,name=actors_fight_time_mod,value=-((-(450)+(time+target.time_to_die))%10),if=time+target.time_to_die>450&time+target.time_to_die<600
            if combatTime + ttd(units.dyn40) > 420 and combatTime + ttd(units.dyn40) < 600 then
                actorsFightTimeMod = - (( - (450) + (combatTime + ttd(units.dyn40))) / 10)
            end
            -- variable,op=set,name=actors_fight_time_mod,value=((450-(time+target.time_to_die))%5),if=time+target.time_to_die<=450
            if combatTime + ttd(units.dyn40) <= 450 then
                actorsFightTimeMod = ((450 - (combatTime + ttd(units.dyn40))) / 5)
            end
            -- variable,op=set,name=s2mcheck,value=(0.8*(83-(5*talent.sanlayn.enabled)+(33*talent.reaper_of_souls.enabled)+set_bonus.tier19_2pc*4+8*variable.s2mbeltcheck+((raw_haste_pct*10))*(2+(0.8*set_bonus.tier19_2pc)+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank)-(1*talent.sanlayn.enabled))))-(variable.actors_fight_time_mod*nonexecute_actors_pct)
            s2mCheck = (0.8 * (83 - (5 * sanlayn) + (33 * reaperOfSouls) + t19pc2 * 4 + 8 * s2mBeltCheck + ((UnitSpellHaste("player") * 10)) * (2 + (0.8 * t19pc2) + (1 * reaperOfSouls) + (2 * artifact.rank.massHysteria) - (1 * sanlayn)))) - (actorsFightTimeMod * 1)
            -- variable,op=min,name=s2mcheck,value=180
            if s2mCheck < 180 then s2mCheck = 180 end
        end
        -- Action List - Main
        function actionList_Main()
        -- Surrender To Madness
            -- surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
            if isChecked("Surrender To Madness") and useCDs() then
                if talent.surrenderToMadness and ttd(units.dyn40) <= s2mCheck then
                    if cast.surrenderToMadness() then return end
                end
            end
        -- Mindbender
            -- mindbender,if=talent.mindbender.enabled&((talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck+60)|!talent.surrender_to_madness.enabled)
            if isChecked("Shadowfiend / Mindbender") and useCDs() then
                if talent.mindbender and ((talent.surrenderToMadness and ttd(units.dyn40) > s2mCheck + 60) or not talent.surrenderToMadness) then
                    if cast.mindbender() then return end
                end
            end
        -- Shadow Word: Pain
            -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd.max,moving=1,cycle_targets=1
            if moving and talent.misery and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if debuff.shadowWordPain.remain(thisUnit) < gcd then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
            if talent.misery and debuff.vampiricTouch.count() < getOptionValue("VT Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if (debuff.vampiricTouch.remain(thisUnit) < 3 * gcd or debuff.shadowWordPain.remain(thisUnit) < 3 * gcd) then
                        if cast.vampiricTouch(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word: Pain
            -- shadow_word_pain,if=!talent.misery.enabled&dot.shadow_word_pain.remains<(3+(4%3))*gcd
            if not talent.misery and debuff.shadowWordPain.remain(units.dyn40) < (3 + (4 / 3)) * gcd then
                if cast.shadowWordPain() then return end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=!talent.misery.enabled&dot.vampiric_touch.remains<(4+(4%3))*gcd
            if not talent.misery and debuff.vampiricTouch.remain(units.dyn40) < (3 + (4 / 3)) * gcd then
                if cast.vampiricTouch() then return end
            end
        -- Void Eruption
            -- void_eruption,if=insanity>=70|(talent.auspicious_spirits.enabled&insanity>=(65-shadowy_apparitions_in_flight*3))|set_bonus.tier19_4pc
            if power >= 70 or (talent.auspiciousSpirits and power >= (65 - 3)) or t19_4pc then -- TODO: Track Auspicious Spirits In Flight
                if cast.voidEruption("player") then return end
            end
        -- Shadow Crash
            -- shadow_crash,if=talent.shadow_crash.enabled
            if talent.shadowCrash then
                if cast.shadowCrash("best",nil,1,8) then return end
            end
        -- Mindbender
            -- mindbender,if=talent.mindbender.enabled&set_bonus.tier18_2pc
            if isChecked("Shadowfiend / Mindbender") and useCDs() then
                if talent.mindbender and tier18_2pc then
                    if cast.mindbender() then return end
                end
            end
        -- Shadow Word: Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
            if not talent.misery and talent.legacyOfTheVoid and power >= 70 and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.shadowWordPain.exists(thisUnit) then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
            if not talent.misery and talent.legacyOfTheVoid and power >= 70 and debuff.vampiricTouch.count() < getOptionValue("VT Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.vampiricTouch.exists(thisUnit) then
                        if cast.vampiricTouch(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word: Death
            -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2&insanity<=(85-15*talent.reaper_of_souls.enabled)
            if (((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 3) or (talent.reaperOfSouls and ((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 2)))
                and charges.shadowWordDeath == 2 and power <= (85 - 15 * reaperOfSouls) and thp < 20
            then
                if cast.shadowWordDeath() then return end
            end
        -- Mind Blast
            -- mind_blast,if=active_enemies<=4&talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
            if ((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 3) and talent.legacyOfTheVoid and (power <= 81 or (power <= 75.2 and talent.fortressOfTheMind)) then
                if cast.mindBlast() then return end
            end
        -- Mind Blast
            -- mind_blast,if=active_enemies<=4&!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
            if ((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 3) and not talent.legacyOfTheVoid and (power <= 96 or (power <= 95.2 and talent.fortressOfTheMind)) then
                if cast.mindBlast() then return end
            end
        -- Shadow Word: Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
            if not talent.mistery and ((mode.rotation == 1 and #enemies.yards40 < 5) or mode.rotation == 3)
                and (talent.auspiciousSpirits or talent.shadowyInsight) and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.shadowWordPain.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
            if not talent.mistery and (((mode.rotation == 1 and #enemies.yards40 < 4) or mode.rotation == 3) or talent.sanlayn or (talent.auspiciousSpirits and artifact.unleashTheShadows))
                and debuff.vampiricTouch.count() < getOptionValue("VT Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.vampiricTouch.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.vampiricTouch(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word: Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
            if not talent.misery and ((mode.rotation == 1 and #enemies.yards40 < 5) or mode.rotation == 3)
                and artifact.sphereOfInsanity and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.shadowWordPain.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word: Void
            -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity<=70&talent.legacy_of_the_void.enabled)|(insanity<=85&!talent.legacy_of_the_void.enabled)
            if talent.shadowWordVoid and ((power <= 70 and talent.legacyOfTheVoid) or (power <= 85 and not talent.legacyOfTheVoid)) then
                if cast.shadowWordVoid() then return end
            end
        -- Mind Flay
            if talent.mindSpike then
                if cast.mindSpike() then return end
            elseif not isCastingSpell(spell.mindFlay) then
                if cast.mindFlay() then return end
            end
        -- Shadow Word: Pain
            if not debuff.shadowWordPain.exists(units.dyn40) then
                if cast.shadowWordPain() then return end
            end
        end
        -- Action List - Surrender To Madness
        function actionList_SurrenderToMadness()
        -- Void Bolt
            -- void_bolt,if=buff.insanity_drain_stacks.stack<6&set_bonus.tier19_4pc
            -- if buff.insanity

        end -- End Action List - Surrender To Madness
    -- Action List - VoidForm
        function actionList_VoidForm()
        -- Surrender to Madness
            -- surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=variable.s2mcheck-(buff.insanity_drain_stacks.stack)
            if isChecked("Surrender To Madness") and useCDs() then
                if talent.surrenderToMadness and power >= 25 and (cd.voidBolt == 0 or cd.voidTorrent == 0 or cd.shadowWordDeath == 0 or buff.shadowyInsight.exists())
                    and ttd(units.dyn40) <= s2mCheck - (drainStacks)
                then
                    if cast.surrenderToMadness() then return end
                end
            end
        -- Void Bolt
            -- void_bolt
            if cast.voidBolt() then return end
        -- Shadow Crash
            -- shadow_crash,if=talent.shadow_crash.enabled
            if talent.shadowCrash then
                if cast.shadowCrash("best",nil,1,8) then return end
            end
        -- Void Torrent
            -- void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60))
            if debuff.shadowWordPain.remain(units.dyn40) > 5.5 and debuff.vampiricTouch.remain(units.dyn40) > 5.5
                and (not talent.surrenderToMadness or (talent.surrenderToMadness and ttd(units.dyn40) > s2mCheck - (drainStacks) + 60))
            then
                if cast.voidTorrent() then return end
            end
        -- Mindbender
            -- mindbender,if=talent.mindbender.enabled&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+30))
            if isChecked("Shadowfiend / Mindbender") and useCDs() then
                if talent.mindbender and (not talent.surrenderToMadness or (talent.surrenderToMadness and ttd(units.dyn40) > s2mCheck - (drainStacks) + 30)) then
                    if cast.mindbender() then return end
                end
            end
        -- Power Infusion
            -- power_infusion,if=buff.insanity_drain_stacks.stack>=(10+2*set_bonus.tier19_2pc+5*buff.bloodlust.up+5*variable.s2mbeltcheck)&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+61))
            if isChecked("Power Infusion") and useCDs() then
                if drainStacks >= (10 + 2 * t19pc2 + 5 * lusting + 5 * s2mBeltCheck)
                    and (not talent.surrenderToMadness or (talent.surrenderToMadness and ttd(units.dyn40) > s2mCheck - (drainStacks) + 61))
                then
                    if cast.powerInfusion("player") then return end
                end
            end
        -- Berserking
            -- berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=20&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60))
            if br.player.race == "Troll" and getSpellCD(racial) == 0 and buff.voidForm.stack() >= 10 and drainStacks <= 20
                and (not talent.surrenderToMadness or (talent.surrenderToMadness and ttd(units.dyn40) > s2mCheck - (drainStacks) + 60))
            then
                if castSpell("player",racial,false,false,false) then return end
            end
        -- Void Bolt
            -- void_bolt
            if cast.voidBolt() then return end
        -- Shadow Word - Death
            -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(15+15*talent.reaper_of_souls.enabled))<100
            if ((mode.rotation == 1 and (#enemies.yards40 <= 4 or (talent.reaperOfSouls and #enemies <= 2))) or mode.rotation == 3)
                and insanityDrain * gcd > power and (power - (insanityDrain * gcd) + (15 + 15 * reaperOfSouls)) < 100 and thp < 20
            then
                if cast.shadowWordDeath() then return end
            end
        -- Wait For Void Bolt
            -- wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
            if cd.voidBolt < gcd * 0.28 then
                return true
            end
        -- Mind Blast
            -- mind_blast,if=active_enemies<=4
            if ((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 3) then
                if cast.mindBlast() then return end
            end
        -- Wait For Mind Blast
            -- wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=4
            if ((mode.rotation == 1 and #enemies.yards40 <= 4) or mode.rotation == 3) and cd.mindBlast < gcd * 0.28 then
                return true
            end
        -- Shadow Word - Death
            -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2
            if ((mode.rotation == 1 and (#enemies.yards40 <= 4 or (talent.reaperOfSouls and #enemies <= 2))) or mode.rotation == 3) and charges.shadowWordDeath == 2 and thp < 20 then
                if cast.shadowWordDeath() then return end
            end
        -- Shadowfiend
            -- shadowfiend,if=!talent.mindbender.enabled,if=buff.voidform.stack>15
            if isChecked("Shadowfiend / Mindbender") and useCDs() then
                if not talent.mindbender and buff.voidForm.stacks > 15 then
                    if cast.shadowfiend() then return end
                end
            end
        -- Shadow Word - Void
            -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+25)<100
            if talent.shadowWordVoid and (power - (insanityDrain * gcd) + 25) < 100 then
                if cast.shadowWordVoid() then return end
            end
        -- Shadow Word - Pain
            -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
            if talent.misery and moving and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if debuff.shadowWordPain.remain(thisUnit) < gcd then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
            if talent.misery and debuff.vampiricTouch.count() < getOptionValue("VT Max Targets") then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if debuff.vampiricTouch.remain(thisUnit) < 3 * gcd or debuff.shadowWordPain.remain(thisUnit) < 3 * gcd then
                        if cast.vampiricTouch(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word - Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
            if not talent.misery and not debuff.shadowWordPain.exists()
                and (((mode.rotation == 1 and #enemies.yards40 < 5) or mode.rotation == 3) or talent.auspiciousSpirits or talent.shadowyInsight or artifact.sphereOfInsanity)
            then
                if cast.shadowWordPain() then return end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
            if not talent.misery and not debuff.vampiricTouch.exists()
                and (((mode.rotation == 1 and #enemies.yards40 < 4) or mode.rotation == 3) or talent.sanlayn or (talent.auspiciousSpirits and artifact.unleashTheShadows))
            then
                if cast.vampiricTouch() then return end
            end
        -- Shadow Word - Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
            if not talent.misery and (((mode.rotation == 1 and #enemies.yards40 < 5) or mode.rotation == 3)
                and (talent.auspiciousSpirits or talent.shadowyInsight or artifact.sphereOfInsanity)) and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.shadowWordPain.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Vampiric Touch
            -- vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
            if not talent.misery and (((mode.rotation == 1 and #enemies.yards40 < 4) or mode.rotation == 3) or talent.sanlayn or (talent.auspiciousSpirits and artifact.unleashTheShadows))
                and debuff.vampiricTouch.count() < getOptionValue("VT Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.vampiricTouch.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.vampiricTouch(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Shadow Word - Pain
            -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
            if not talent.misery and (((mode.rotation == 1 and #enemies.yards40 < 5) or mode.rotation == 3)
                and artifact.sphereOfInsanity) and debuff.shadowWordPain.count() < getOptionValue("SWP Max Targets")
            then
                for i = 1, #enemies.yards40 do
                    local thisUnit = enemies.yards40[i]
                    if not debuff.shadowWordPain.exists(thisUnit) and ttd(thisUnit) > 10 then
                        if cast.shadowWordPain(thisUnit,"aoe") then return end
                    end
                end
            end
        -- Mind Flay
            -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100&cooldown.shadow_word_death.charges>=1))
            if mfTick >= 2 and (cd.voidBolt == 0 or (insanityDrain * gcd > power and (power - (insanityDrain * gcd) + 30) < 100 and charges.shadowWordDeath >= 1)) then
                return true
            else
                if cast.mindFlay() then return end
            end
        -- Shadow Word - Pain
            -- shadow_word_pain
            if cast.shadowWordPain() then return end
        end -- End Action List - VoidForm
-----------------
--- Rotations ---
-----------------
        if not IsMounted() then
            if actionList_Extra() then return end
            if actionList_Defensive() then return end
        end
---------------------------------
--- Out Of Combat - Rotations ---
---------------------------------
        if not inCombat then --  and ObjectExists("target") and not UnitIsDeadOrGhost("target") and UnitCanAttack("target", "player")
            if actionList_PreCombat() then return end
        end
-----------------------------
--- In Combat - Rotations ---
-----------------------------
        if inCombat and not IsMounted() and isValidUnit(units.dyn40) and getDistance(units.dyn40) < 40 and not isCastingSpell(spell.voidTorrent) then
        -- Action List - Check
            -- call_action_list,name=check,if=talent.surrender_to_madness.enabled&!buff.surrender_to_madness.up
            if talent.surrenderToMadness and not buff.surrenderToMadness then
                if actionList_Check() then return end
            end
        -- Action List - Void Form
            -- run_action_list,name=vf,if=buff.voidform.up
            if buff.voidForm.exists() then
                if actionList_VoidForm() then return end
            end
        -- Action List - Main
            -- run_action_list,name=main
            if actionList_Main() then return end
        end -- End Combat Rotation
    end -- End Timer
end -- Run Rotation

local id = 258
if br.rotations[id] == nil then br.rotations[id] = {} end
tinsert(br.rotations[id],{
    name = rotationName,
    toggles = createToggles,
    options = createOptions,
    run = runRotation,
})
