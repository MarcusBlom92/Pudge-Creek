require("hero_selector")
require("util")

SURVIVORS = 0;

CONNECTED_PLAYERS = 0;
ASSIGNED_HEROES = 0;

PUDGE = nil;

players = {}
tombstoneVisionUnits = {}

if PudgeCreek == nil then
	PudgeCreek = class({})
end

function CosmeticIsForHero(hero,itemlist)

	for k,v in pairs(itemlist) do
		if(k == 'used_by_heroes') then
			if type(v) == "table" then
				for key,value in pairs(v) do
					if key == hero then
						return true;
					end
				end
			end
		end
	end

	return false

end

function CosmeticIsForHeroes(heroList,itemlist)

	for i=1, #heroes do
		if CosmeticIsForHero('npc_dota_hero_' .. heroes[i],itemlist) then
			return true;
		end
	end

	return CosmeticIsForHero('npc_dota_hero_pudge',itemlist)
end

function Precache( context )

	PrecacheResource("particle_folder", "particles/units/heroes/hero_pudge", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_slark",context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_rubick",context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_tiny",context)
	PrecacheResource("particle_folder", "particles/units/heroes/zuus",context)

	PrecacheResource("particle_folder", "particles/models/items/lina",context)
	PrecacheResource("particle_folder", "particles/models/items/enchantress",context)
	PrecacheResource("particle_folder", "particles/models/items/antimage",context)
	PrecacheResource("particle_folder", "particles/models/items/crystal_maiden",context)

	PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
	PrecacheUnitByNameSync("npc_dota_hero_zuus", context)
	PrecacheUnitByNameSync("npc_dota_hero_furion", context)
	PrecacheUnitByNameSync("npc_dota_hero_pudge_template",context)
	HeroSelector:Precache(context)

	PrecacheItemByNameSync( "item_tombstone", context )

	local wearables = LoadKeyValues("scripts/items/items_game.txt")

	local wearablesList = {}
	local precacheWearables = {}
	for k, v in pairs(wearables) do
		if k == 'items' then
			wearablesList = v
		end
	end
	local counter = 0

	--check wearablesList for certain hero cosmetics
	for k, v in pairs(wearablesList) do
	  	if CosmeticIsForHeroes(heroes, wearablesList[k]) then
            for key, value in pairs(wearablesList[k]) do
				if key == 'model_player' then
					counter = counter+1
					precacheWearables[value] = true
				end
			end
		end
	end

	for wearable,_ in pairs( precacheWearables ) do
		--print("Precache: " .. wearable)
		PrecacheResource( "model", wearable, context )
	end
	--print('[Precache]' .. counter .. " models loaded!")
	--print('[Precache] End')


end

function Activate()
    GameRules.AddonTemplate = PudgeCreek()
    GameRules.AddonTemplate:InitGameMode()
end

function PudgeCreek:InitGameMode()

	local GameMode = GameRules:GetGameModeEntity()

	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetGoldPerTick(0)
	GameRules:SetHeroSelectionTime(0.0)
	GameRules:SetPreGameTime(0.0)
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetCustomGameSetupTimeout(30)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,1)

	local xp_level_table =
	{
		0
	}

	GameMode:SetCustomXPRequiredToReachNextLevel(xp_level_table)
	GameMode:SetUseCustomHeroLevels(true)

	GameMode:SetCameraDistanceOverride(1800)
	GameMode:SetBuybackEnabled(false)

	ListenToGameEvent("player_connect_full", Dynamic_Wrap(PudgeCreek, 'OnPlayerConnectFull'), self);
	ListenToGameEvent('entity_killed', Dynamic_Wrap(PudgeCreek, 'OnEntityKilled'), self);
	ListenToGameEvent('game_rules_state_change',Dynamic_Wrap(PudgeCreek,'OnGameStateChange'),self);
	ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( PudgeCreek, 'OnHoldoutReviveComplete' ), self )

end

function PudgeCreek:OnGameStateChange(keys)

	local state = GameRules:State_Get()



	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--Assign heroes to player based on their selected team.

		-- Start at night.
		GameRules:SetTimeOfDay(0.75)

		-- Now give the players new heroes depending on their team.
			for i=1, #players do
				local player = players[i]
				if (player ~= nil) then

					local hero

					local team = player:GetTeam()
					if team then
						if team == DOTA_TEAM_BADGUYS then -- create pudge

							PUDGE = player
							hero = CreateHeroForPlayer('npc_dota_hero_pudge', player)

							hero:SetGold(0, false)
						  hero:SetAbilityPoints(0)

							hero:SetNightTimeVisionRange(1450)

							hero:SetBaseHealthRegen(0.0)
							hero:SetBaseStrength(0.0)

							hero:GetAbilityByIndex(0):SetLevel(1)
							hero:GetAbilityByIndex(1):SetLevel(1)
							hero:GetAbilityByIndex(2):SetLevel(1)
							hero:GetAbilityByIndex(3):SetLevel(1)
							-- Pudge starts with a force staff.
							local item = CreateItem("item_pudge_creek_force_staff", hero, hero)
							hero:AddItem(item)


						else if team == DOTA_TEAM_GOODGUYS then -- create random survivor


							local hero_name = "npc_dota_hero_" .. HeroSelector:GetRandomHeroName()

							hero = CreateHeroForPlayer(hero_name, player);
							SURVIVORS = SURVIVORS + 1;
							print("Setting up hero attributes")
							hero:SetGold(0, false)
						  hero:SetAbilityPoints(0)
							hero:SetBaseMoveSpeed(475)

							hero:SetNightTimeVisionRange(1050)

							--Set up the surviors abilities

							--Remove preious abilities for the hero
							for i = 0, 6 do
						    local ab = hero:GetAbilityByIndex(i)
						    if ab then
						      hero:RemoveAbility(ab:GetAbilityName())
						    end
						  end

							--Add the new abilities
							hero:AddAbility("pudge_creek_phase_shift")
							hero:AddAbility("pudge_creek_dragon_tail")
							hero:AddAbility("pudge_creek_pounce")
							hero:AddAbility("pudge_creek_track")

							--Add points to the abilities
							hero:GetAbilityByIndex(0):SetLevel(1)
							hero:GetAbilityByIndex(1):SetLevel(1)
							hero:GetAbilityByIndex(2):SetLevel(1)
							hero:GetAbilityByIndex(3):SetLevel(1)

						end
					end
				end
					--PlayerResource:SetGold(player:GetPlayerID(),0,true)
					end
			end
	end

end

function PudgeCreek:OnEntityKilled(keys)

		PrintTable(keys)
		local killedEntity = EntIndexToHScript(keys.entindex_killed)
		local attackerEntity = EntIndexToHScript(keys.entindex_attacker)

			if (killedEntity ~= nil) and (killedEntity:IsRealHero() == true) then
				-- If a survivor has died
				if (killedEntity:GetTeam() == DOTA_TEAM_GOODGUYS)  then

						SURVIVORS = SURVIVORS - 1

						-- Create tombstone on pudges location.
						-- The player will die instantly when connecting with the hook,
						-- however the body will move towards pudge.

						local tombstoneLocation = attackerEntity:GetAbsOrigin()
						local newItem = CreateItem( "item_tombstone", killedEntity, killedEntity )
						newItem:SetPurchaseTime( 0 )
						newItem:SetPurchaser( killedEntity )
						local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
						tombstone:SetContainedItem( newItem )
						tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
						FindClearSpaceForUnit( tombstone, tombstoneLocation, true )

						--Place two vision units on tombstone location, one for each team.
						local tombstoneVisionPudge = CreateUnitByName("npc_vision_unit_pudge", tombstoneLocation, false, nil, nil, DOTA_TEAM_BADGUYS)
						tombstoneVisionPudge:GetAbilityByIndex(0):SetLevel(1)
						--FindClearSpaceForUnit( tombstoneVisionPudge, tombstoneLocation, true )

						local tombstoneVisionSurvivors = CreateUnitByName("npc_vision_unit", tombstoneLocation, false, nil, nil, DOTA_TEAM_GOODGUYS)
						tombstoneVisionSurvivors:GetAbilityByIndex(0):SetLevel(1)
						--FindClearSpaceForUnit( tombstoneVisionSurvivors, tombstoneLocation, true )

						--Update the vision table with the new vision units.
						tombstoneVisionUnits[killedEntity:GetPlayerOwnerID()] = {}
						tombstoneVisionUnits[killedEntity:GetPlayerOwnerID()][0] = tombstoneVisionPudge
						tombstoneVisionUnits[killedEntity:GetPlayerOwnerID()][1] = tombstoneVisionSurvivors


						if SURVIVORS <= 0 then -- pudge wins
								GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
								GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
								GameRules:Defeated()
						end

				-- if pudge has died
				elseif (killedEntity:GetTeam() == DOTA_TEAM_BADGUYS) then
					-- Radiant side wins
					GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
				end
		end
end

function PudgeCreek:OnHoldoutReviveComplete( event )

	PrintTable(event)

	local castingHero = EntIndexToHScript( event.caster )
	local revivedHero = EntIndexToHScript(event.target)
	if castingHero then

		local nPlayerID = castingHero:GetPlayerOwnerID()
		-- Increment the count of living survivors.
		SURVIVORS = SURVIVORS + 1

		--Remove tombstones associated with the ressurected player.
		local revivedPlayerID = revivedHero:GetPlayerOwnerID()
		local pudgeVision = tombstoneVisionUnits[revivedPlayerID][0]
		local survivorVision = tombstoneVisionUnits[revivedPlayerID][1]

		if pudgeVision then
			UTIL_Remove(pudgeVision)
		end
		if survivorVision then
			UTIL_Remove(survivorVision)
		end

	end
end

function PudgeCreek:OnPlayerConnectFull(keys)
	local player = PlayerInstanceFromIndex(keys.index + 1)
	players[CONNECTED_PLAYERS + 1] = player
	CONNECTED_PLAYERS = CONNECTED_PLAYERS + 1
end
