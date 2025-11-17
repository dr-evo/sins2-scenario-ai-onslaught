local total_conversion_percent_for_victory = 0.5
total_currently_converted = 0.0
local human_player = nil

function setup_scenario (simulation)
end

function setup_player (simulation, player)
end

function post_game_load (simulation)
    for index, player in pairs(simulation.players) do
        if player.is_human then
            human_player = player
        end
    end

    simulation:set_total_percent_needed_to_convert(total_conversion_percent_for_victory)
end

function on_update (simulation, time_elapsed)

    local victory = check_for_victory_condition(simulation)
    if not simulation.is_game_over then
        if victory then
            simulation:player_victory(human_player, player_victory.diplomatic)
        elseif is_player_dead(human_player) then
            simulation:player_defeat(human_player, player_victory.military)
            simulation:set_game_over()
        end
    end
    local enemy_planets = simulation:get_enemy_planets_with_your_allegiance()
    
    if #enemy_planets > 0 then
        simulation:convert_enemy_planet_with_your_allegiance()

    for i, planet in ipairs(enemy_planets) do
        simulation:unit_apply_buff(planet, "advent_unity_sanctify")
    end
end
end

function check_for_victory_condition (simulation)

    total_currently_converted = simulation:get_percent_converted_in_galaxy(simulation);
    if total_currently_converted >= total_conversion_percent_for_victory then
        return true
    end

    return false
end

function on_game_save (simulation)
    serialize("total_currently_converted", total_currently_converted)
end

function on_game_over (simulation)
end

function is_player_dead(player)
    if player == nil then
        return true
    end

    -- Efficiency hack
    local next = next
    
    -- Check if the player has no owned planets and no alive rulerships
    return not next(player.owned_planets) and not next(player.alive_rulerships)
end
