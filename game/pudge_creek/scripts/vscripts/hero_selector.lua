
if HeroSelector == nil then
  HeroSelector = {}
  HeroSelector.__index = HeroSelector
end

function HeroSelector:new( o )
  o = o or {}
  setmetatable( o, HeroSelector )
  return o
end

heroes = 	{ 	
					'lina', 
					'enchantress', 
					'invoker', 
					'omniknight' , 
					'antimage' ,
					'crystal_maiden',
					'windrunner',
					'witch_doctor',
					'kunkka',
					'wisp',
					'puck'
					
			}
			
chosenHeroes = {}    
    for i=1, #heroes do
      chosenHeroes[i] = false
    end			

chosenHeroesCount = 0
	
function HeroSelector:GetRandomHeroName()
	local heroIndex = RandomInt(1, #heroes )
	
	if(chosenHeroes[heroIndex])
	then
		while(chosenHeroes[heroIndex])
		do
			heroIndex = heroIndex + 1
			if(heroIndex > #heroes)
			then
				heroIndex = 0
			end
		end
	end
	
	local result = heroes[ heroIndex ]
	chosenHeroes[heroIndex] = true;
	chosenHeroesCount = 1
	
	if(chosenHeroesCount >= #heroes)
	then
		for i=1, #heroes do
			chosenHeroes[i] = false
		end	
	end
	
	return result
end

function HeroSelector:Precache(context)
	
	
	
	for heroIndex = 1, #heroes do
	  PrecacheResource("particle_folder", "particles/units/heroes/hero_" .. heroes[heroIndex], context)
	end
	
	for heroIndex = 1, #heroes do
	  PrecacheResource("model_folder","models/heroes/" .. heroes[heroIndex],context)
	end
	
	for heroIndex = 1, #heroes do
	  PrecacheUnitByNameSync("npc_dota_hero_" .. heroes[heroIndex], context)
	end
end