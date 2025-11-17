local time_to_win = 300
local required_titans = 3

local normal_players = {}
aluxian_player_id = -1
local aluxian_planet = nil
aluxian_planet_id = -1
cur_countdown = time_to_win
local controlling_player = nil
controlling_player_id = -1
local human_player

function setup_scenario(simulation)
end

function setup_player(simulation, player)
end

function post_game_load(simulation)
    if aluxian_planet_id ~= -1 then
        for index, planet in pairs(simulation.planets) do
            if planet.id == aluxian_planet_id then
                aluxian_planet = planet
            end
        end
    else
        for index, player in pairs(simulation.players) do
            if player.is_npc and player.race == "cot_aluxian_resurgence_npc" then
                aluxian_player_id = player.id
                aluxian_planet = player.home_planet
                aluxian_planet_id = aluxian_planet.id
            elseif player.is_human then
                human_player = player
            end
        end
    end

    if controlling_player_id ~= -1 then
        for index, player in pairs(simulation.players) do
            if player.id == controlling_player_id then
                controlling_player = player
            end
        end
    end

    simulation:set_current_player_concurrent_titans_built_required_for_victory(required_titans)
    simulation:set_unique_scenario_manager_with_aluxi_owner(aluxian_planet.owner_player)
    simulation:set_unique_scenario_manager_with_timer(cur_countdown)
end

function on_update(simulation, time_elapsed)
    local cur_owner = aluxian_planet.owner_player

    if cur_owner ~= nil and cur_owner.id == aluxian_player_id then
        simulation:set_unique_scenario_manager_with_aluxi_owner(cur_owner)
    end

    if cur_owner == nil or cur_owner.id == aluxian_player_id then
        return
    end
    
    if controlling_player == nil or controlling_player.id ~= cur_owner.id then
        controlling_player = cur_owner
        controlling_player_id = controlling_player.id
        cur_countdown = time_to_win
        simulation:set_unique_scenario_manager_with_timer(cur_countdown)
        simulation:set_unique_scenario_manager_with_aluxi_owner(controlling_player)
    else
        cur_countdown = math.max(math.floor(cur_countdown - time_elapsed), 0)
        simulation:set_unique_scenario_manager_with_timer(cur_countdown)
    end
    
    if not simulation.is_game_over and cur_countdown == 0 then
        simulation:player_victory(controlling_player, player_victory.colonization)
    end
end

function on_game_save (simulation)
    serialize("aluxian_player_id", aluxian_player_id)
    serialize("aluxian_planet_id", aluxian_planet_id)
    serialize("cur_countdown", cur_countdown)
    serialize("controlling_player_id", controlling_player_id)
end

function on_game_over (simulation)
end
