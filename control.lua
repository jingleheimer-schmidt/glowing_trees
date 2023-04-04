
-- ---create a waypoint for a given entity and player index
-- ---@param target LuaEntity | LuaUnitGroup
-- ---@return CutsceneWaypoint
-- local function create_target_waypoint(target)
-- 	---@type CutsceneWaypoint
-- 	local waypoint = {
-- 		target = target,
-- 		transition_time = 0,
-- 		time_to_wait = 60 * 60 * 60,
-- 		-- zoom = 0.3
-- 	}
-- 	return waypoint
-- end

-- ---create a waypoint for a given position and player index
-- ---@param position MapPosition
-- ---@return CutsceneWaypoint
-- local function create_position_waypoint(position)
-- 	---@type CutsceneWaypoint
-- 	local waypoint = {
-- 		position = position,
-- 		transition_time = 0,
-- 		time_to_wait = 60 * 60 * 60,
-- 		-- zoom = 0.3
-- 	}
-- 	return waypoint
-- end

-- ---begin cutscene for player with given waypoints
-- ---@param waypoints CutsceneWaypoint[]
-- ---@param player LuaPlayer
-- local function play_cutscene(waypoints, player)
-- 	player.set_controller(
-- 		{
-- 			type = defines.controllers.cutscene,
-- 			waypoints = waypoints,
-- 		}
-- 	)
-- end

-- local function update_cutscene(data)
-- 	local target = data.entity or data.group
-- 	for key, player in pairs(game.connected_players) do
-- 		local waypoint = create_target_waypoint(target)
-- 		play_cutscene(waypoint, player)
-- 	end
-- end

-- script.on_event(defines.events.on_unit_group_finished_gathering, update_cutscene(data))