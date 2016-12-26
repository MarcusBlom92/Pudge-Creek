function RessurectionStart(keys)
    print("Rezing!")
    local caster = keys.caster
    local casterPos = caster:GetAbsOrigin()
    MinimapEvent(DOTA_TEAM_BADGUYS, caster, casterPos.x, casterPos.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2)
    AddFOWViewer( nTeamID, casterPos, 10.0, 10.0, true)
end

function Hunger(keys)
    local caster = keys.caster

    --local dps = keys.ability:GetSpecialValueFor("dot_damage") / 10

    --if caster:GetHealth() == 1 then
        local damageTable =
        {
          victim = caster,
          attacker = caster,
          damage = 11.3,
          damage_type = DAMAGE_TYPE_PURE,
        }

        ApplyDamage(damageTable)
  --  end


end
