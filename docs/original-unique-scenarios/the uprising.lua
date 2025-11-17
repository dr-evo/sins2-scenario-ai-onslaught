local enemy_home_planets_captured_for_victory = 6
local insurgency = false
local insurgency_fleet_supply = 5000
local time_to_win = 300
enemy_planet_1 = nil
enemy_planet_2 = nil
enemy_planet_3 = nil
enemy_planet_4 = nil
enemy_planet_5 = nil
enemy_planet_6 = nil
cur_countdown = time_to_win

function setup_scenario(simulation)
    setup_enemy_home_planet_ids(simulation)
end

function setup_player(simulation, player)
end

function post_game_load(simulation)
    simulation:set_unique_scenario_manager_enemy_home_planets_captured_for_victory(enemy_home_planets_captured_for_victory)
    simulation:set_unique_scenario_manager_with_timer(cur_countdown)
end

function setup_enemy_home_planet_ids(simulation)
    for _, planet in ipairs(simulation.planets) do
        if planet.is_planet and planet.is_home_planet_of_playable_owner_player then
            local owner = planet.owner_player
            if owner then
                if owner.id == 1 then
                    enemy_planet_1 = planet.id
                elseif owner.id == 2 then
                    enemy_planet_2 = planet.id
                elseif owner.id == 3 then
                    enemy_planet_3 = planet.id
                elseif owner.id == 4 then
                    enemy_planet_4 = planet.id
                elseif owner.id == 5 then
                    enemy_planet_5 = planet.id
                elseif owner.id == 6 then
                    enemy_planet_6 = planet.id
                end
            end
        end
    end
end

function on_update(simulation, time_elapsed)

    if not insurgency and get_total_used_supply(simulation) >= insurgency_fleet_supply then
        insurgency = true
        grant_insurgency_research(simulation)
    end

    local enemy_home_planets_captured = get_enemy_home_planets_captured(simulation)
    simulation:set_unique_scenario_manager_enemy_home_planets_captured_by_player(enemy_home_planets_captured)

    if enemy_home_planets_captured >= enemy_home_planets_captured_for_victory then
        cur_countdown = math.max(math.floor(cur_countdown - time_elapsed), 0)
    else
        cur_countdown = time_to_win
    end
    simulation:set_unique_scenario_manager_with_timer(cur_countdown)

    if not simulation.is_game_over and cur_countdown <= 0 then
        for _, player in ipairs(simulation.players) do
            if player.is_human then
                simulation:player_victory(player, player_victory.colonization)
            end
        end
    end
end

function on_game_save(simulation)
    serialize("enemy_planet_1", enemy_planet_1)
    serialize("enemy_planet_2", enemy_planet_2)
    serialize("enemy_planet_3", enemy_planet_3)
    serialize("enemy_planet_4", enemy_planet_4)
    serialize("enemy_planet_5", enemy_planet_5)
    serialize("enemy_planet_6", enemy_planet_6)
    serialize("cur_countdown", cur_countdown)
end

function on_game_over(simulation)
end

function get_total_used_supply(simulation)
    local total_used_supply = 0

    for _, player in ipairs(simulation.players) do
        if not player.is_npc then
            total_used_supply = total_used_supply + player.used_supply
        end
    end

    return total_used_supply
end

function grant_insurgency_research(simulation)
    for _, player in ipairs(simulation.players) do
        if not player.is_npc and player.id ~= 0 then
            simulation:give_research(player, "trader_culture_insurgency")
        end
    end
end

function get_planet_by_id(simulation, id)
    for index, planet in ipairs(simulation.planets) do
        if planet.id == id then
            return planet
        end
    end

    return nil
end

function get_enemy_home_planets_captured(simulation)
    local enemy_home_planets_captured = 0

    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_1)
    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_2)
    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_3)
    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_4)
    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_5)
    enemy_home_planets_captured = enemy_home_planets_captured + get_enemy_home_planet_captured(simulation, enemy_planet_6)

    return enemy_home_planets_captured
end

function get_enemy_home_planet_captured(simulation, planet_id)

    local planet = get_planet_by_id(simulation, planet_id)

    if planet then
        local owner = planet.owner_player

        if owner and owner.player_index == 0 then
            return 1
        end
    end

    return 0
end
