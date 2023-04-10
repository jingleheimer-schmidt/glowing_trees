
local table = require("__flib__.table")

local glow_scales = {
    ["Tiny"] = 4,
    ["Small"] = 5,
    ["Medium"] = 6,
    ["Large"] = 7,
    ["Huge"] = 8,
    ["Enormous"] = 9,
}

local glow_chance_percents = {
    ["None"] = 0,
    ["Few"] = 0.125,
    ["Some"] = 0.25,
    ["Half"] = 0.5,
    ["Most"] = 0.75,
    ["All"] = 1,
}

local light_scale_and_intensity = {
    ["Tiny"] = {scale = 5, intensity = 0.3},
    ["Small"] = {scale = 6, intensity = 0.25},
    ["Medium"] = {scale = 7, intensity = 0.2},
    ["Large"] = {scale = 9, intensity = 0.15},
    ["Huge"] = {scale = 11, intensity = 0.1},
    ["Enormous"] = {scale = 15, intensity = 0.05},
}

local function rainbow_color(anchor)
    local speed = 0.01
    local r = math.sin(anchor * speed + 0) * 127 + 128
    local g = math.sin(anchor * speed + 2) * 127 + 128
    local b = math.sin(anchor * speed + 4) * 127 + 128
    return {r = r, g = g, b = b, a = 0.5}
end
-- ---@param position MapPosition
-- ---@param surface_name string
-- ---@return string
-- local function unique_id(position, surface_name)
--     local x = position.x
--     local y = position.y
--     return surface_name .. " " .. x .. " " .. y
-- end

-- local function unique_id(position, surface_index, concat, temp_table)
--     temp_table = {}
--     temp_table[1] = position.x
--     temp_table[2] = position.y
--     temp_table[3] = surface_index
--     local uuid = concat(temp_table, ", ")
--     return uuid
-- end
-- local function unique_id(position, surface_index, format)
--     local uuid = format("%d, %d, %d", position.x, position.y, surface_index)
--     return uuid
-- end
-- local function unique_id(position, surface_index, format)
--     local uuid =  2^24 * position.x + position.y + surface_index
--     return uuid
-- end
-- local function unique_id(position, surface_index, player_index, format)
--     local uuid = format("%d, %d, %d, %d", player_index, surface_index, position.x, position.y)
--     return uuid
-- end
local function unique_id(position, player_surface_key, format)
    return format("%d, %d, %d", player_surface_key, position.x, position.y)
end
-- local function unique_id(position, surface_index, player_index, bxor, lshift)
--     local uuid = bxor(
--         bxor(
--             lshift(player_index, 16),
--             surface_index
--         ),
--         bxor(
--             lshift(position.x, 16),
--             position.y
--         )
--     )
--     return uuid
-- end
-- local function unique_id(position, surface_index, player_index, format)
--     local uuid = (player_index * 65536 + surface_index) + (position.x * 65536 + position.y)
--     return uuid
-- end
-- local function unique_id(position, surface_index, player_index)
--     local uuid = (position.x + 1e6) + (position.y + 1e6) * 2^21 + surface_index * 2^42 + player_index * 2^58
--     return uuid
-- end

---@param positions MapPosition[]
---@return MapPosition
local function average_position(positions)
    local x = 0
    local y = 0
    for _, position in pairs(positions) do
        x = x + position.x
        y = y + position.y
    end
    return {
        x = x / #positions,
        y = y / #positions,
    }
end

local function average_tree_color_index(trees)
    local color_index = 0
    for _, tree in pairs(trees) do
        color_index = color_index + tree.tree_color_index
    end
    return math.floor(color_index / #trees)
end

local function get_surrounding_quad_positions(position)
    local floor = math.floor
    local step_length = 16
    local pos_x = floor(position.x / step_length)
    local pos_y = floor(position.y / step_length)
    local x_min_8 = (pos_x - 8) * step_length
    local y_min_8 = (pos_y - 8) * step_length
    local x_min_7 = (pos_x - 7) * step_length
    local y_min_7 = (pos_y - 7) * step_length
    local x_min_6 = (pos_x - 6) * step_length
    local y_min_6 = (pos_y - 6) * step_length
    local x_min_5 = (pos_x - 5) * step_length
    local y_min_5 = (pos_y - 5) * step_length
    local x_min_4 = (pos_x - 4) * step_length
    local y_min_4 = (pos_y - 4) * step_length
    local x_min_3 = (pos_x - 3) * step_length
    local y_min_3 = (pos_y - 3) * step_length
    local x_min_2 = (pos_x - 2) * step_length
    local y_min_2 = (pos_y - 2) * step_length
    local x_min_1 = (pos_x - 1) * step_length
    local y_min_1 = (pos_y - 1) * step_length
    local x_0 = (pos_x) * step_length
    local y_0 = (pos_y) * step_length
    local x_add_1 = (pos_x + 1) * step_length
    local y_add_1 = (pos_y + 1) * step_length
    local x_add_2 = (pos_x + 2) * step_length
    local y_add_2 = (pos_y + 2) * step_length
    local x_add_3 = (pos_x + 3) * step_length
    local y_add_3 = (pos_y + 3) * step_length
    local x_add_4 = (pos_x + 4) * step_length
    local y_add_4 = (pos_y + 4) * step_length
    local x_add_5 = (pos_x + 5) * step_length
    local y_add_5 = (pos_y + 5) * step_length
    local x_add_6 = (pos_x + 6) * step_length
    local y_add_6 = (pos_y + 6) * step_length
    local x_add_7 = (pos_x + 7) * step_length
    local y_add_7 = (pos_y + 7) * step_length
    local x_add_8 = (pos_x + 8) * step_length
    local y_add_8 = (pos_y + 8) * step_length
    local quads = {
        {x = x_min_8, y = y_min_8},
        {x = x_min_7, y = y_min_8},
        {x = x_min_6, y = y_min_8},
        {x = x_min_5, y = y_min_8},
        {x = x_min_4, y = y_min_8},
        {x = x_min_3, y = y_min_8},
        {x = x_min_2, y = y_min_8},
        {x = x_min_1, y = y_min_8},
        {x = x_0, y = y_min_8},
        {x = x_add_1, y = y_min_8},
        {x = x_add_2, y = y_min_8},
        {x = x_add_3, y = y_min_8},
        {x = x_add_4, y = y_min_8},
        {x = x_add_5, y = y_min_8},
        {x = x_add_6, y = y_min_8},
        {x = x_add_7, y = y_min_8},
        {x = x_add_8, y = y_min_8},
        {x = x_min_8, y = y_min_7},
        {x = x_min_7, y = y_min_7},
        {x = x_min_6, y = y_min_7},
        {x = x_min_5, y = y_min_7},
        {x = x_min_4, y = y_min_7},
        {x = x_min_3, y = y_min_7},
        {x = x_min_2, y = y_min_7},
        {x = x_min_1, y = y_min_7},
        {x = x_0, y = y_min_7},
        {x = x_add_1, y = y_min_7},
        {x = x_add_2, y = y_min_7},
        {x = x_add_3, y = y_min_7},
        {x = x_add_4, y = y_min_7},
        {x = x_add_5, y = y_min_7},
        {x = x_add_6, y = y_min_7},
        {x = x_add_7, y = y_min_7},
        {x = x_add_8, y = y_min_7},
        {x = x_min_8, y = y_min_6},
        {x = x_min_7, y = y_min_6},
        {x = x_min_6, y = y_min_6},
        {x = x_min_5, y = y_min_6},
        {x = x_min_4, y = y_min_6},
        {x = x_min_3, y = y_min_6},
        {x = x_min_2, y = y_min_6},
        {x = x_min_1, y = y_min_6},
        {x = x_0, y = y_min_6},
        {x = x_add_1, y = y_min_6},
        {x = x_add_2, y = y_min_6},
        {x = x_add_3, y = y_min_6},
        {x = x_add_4, y = y_min_6},
        {x = x_add_5, y = y_min_6},
        {x = x_add_6, y = y_min_6},
        {x = x_add_7, y = y_min_6},
        {x = x_add_8, y = y_min_6},
        {x = x_min_8, y = y_min_5},
        {x = x_min_7, y = y_min_5},
        {x = x_min_6, y = y_min_5},
        {x = x_min_5, y = y_min_5},
        {x = x_min_4, y = y_min_5},
        {x = x_min_3, y = y_min_5},
        {x = x_min_2, y = y_min_5},
        {x = x_min_1, y = y_min_5},
        {x = x_0, y = y_min_5},
        {x = x_add_1, y = y_min_5},
        {x = x_add_2, y = y_min_5},
        {x = x_add_3, y = y_min_5},
        {x = x_add_4, y = y_min_5},
        {x = x_add_5, y = y_min_5},
        {x = x_add_6, y = y_min_5},
        {x = x_add_7, y = y_min_5},
        {x = x_add_8, y = y_min_5},
        {x = x_min_8, y = y_min_4},
        {x = x_min_7, y = y_min_4},
        {x = x_min_6, y = y_min_4},
        {x = x_min_5, y = y_min_4},
        {x = x_min_4, y = y_min_4},
        {x = x_min_3, y = y_min_4},
        {x = x_min_2, y = y_min_4},
        {x = x_min_1, y = y_min_4},
        {x = x_0, y = y_min_4},
        {x = x_add_1, y = y_min_4},
        {x = x_add_2, y = y_min_4},
        {x = x_add_3, y = y_min_4},
        {x = x_add_4, y = y_min_4},
        {x = x_add_5, y = y_min_4},
        {x = x_add_6, y = y_min_4},
        {x = x_add_7, y = y_min_4},
        {x = x_add_8, y = y_min_4},
        {x = x_min_8, y = y_min_3},
        {x = x_min_7, y = y_min_3},
        {x = x_min_6, y = y_min_3},
        {x = x_min_5, y = y_min_3},
        {x = x_min_4, y = y_min_3},
        {x = x_min_3, y = y_min_3},
        {x = x_min_2, y = y_min_3},
        {x = x_min_1, y = y_min_3},
        {x = x_0, y = y_min_3},
        {x = x_add_1, y = y_min_3},
        {x = x_add_2, y = y_min_3},
        {x = x_add_3, y = y_min_3},
        {x = x_add_4, y = y_min_3},
        {x = x_add_5, y = y_min_3},
        {x = x_add_6, y = y_min_3},
        {x = x_add_7, y = y_min_3},
        {x = x_add_8, y = y_min_3},
        {x = x_min_8, y = y_min_2},
        {x = x_min_7, y = y_min_2},
        {x = x_min_6, y = y_min_2},
        {x = x_min_5, y = y_min_2},
        {x = x_min_4, y = y_min_2},
        {x = x_min_3, y = y_min_2},
        {x = x_min_2, y = y_min_2},
        {x = x_min_1, y = y_min_2},
        {x = x_0, y = y_min_2},
        {x = x_add_1, y = y_min_2},
        {x = x_add_2, y = y_min_2},
        {x = x_add_3, y = y_min_2},
        {x = x_add_4, y = y_min_2},
        {x = x_add_5, y = y_min_2},
        {x = x_add_6, y = y_min_2},
        {x = x_add_7, y = y_min_2},
        {x = x_add_8, y = y_min_2},
        {x = x_min_8, y = y_min_1},
        {x = x_min_7, y = y_min_1},
        {x = x_min_6, y = y_min_1},
        {x = x_min_5, y = y_min_1},
        {x = x_min_4, y = y_min_1},
        {x = x_min_3, y = y_min_1},
        {x = x_min_2, y = y_min_1},
        {x = x_min_1, y = y_min_1},
        {x = x_0, y = y_min_1},
        {x = x_add_1, y = y_min_1},
        {x = x_add_2, y = y_min_1},
        {x = x_add_3, y = y_min_1},
        {x = x_add_4, y = y_min_1},
        {x = x_add_5, y = y_min_1},
        {x = x_add_6, y = y_min_1},
        {x = x_add_7, y = y_min_1},
        {x = x_add_8, y = y_min_1},
        {x = x_min_8, y = y_0},
        {x = x_min_7, y = y_0},
        {x = x_min_6, y = y_0},
        {x = x_min_5, y = y_0},
        {x = x_min_4, y = y_0},
        {x = x_min_3, y = y_0},
        {x = x_min_2, y = y_0},
        {x = x_min_1, y = y_0},
        {x = x_0, y = y_0},
        {x = x_add_1, y = y_0},
        {x = x_add_2, y = y_0},
        {x = x_add_3, y = y_0},
        {x = x_add_4, y = y_0},
        {x = x_add_5, y = y_0},
        {x = x_add_6, y = y_0},
        {x = x_add_7, y = y_0},
        {x = x_add_8, y = y_0},
        {x = x_min_8, y = y_add_1},
        {x = x_min_7, y = y_add_1},
        {x = x_min_6, y = y_add_1},
        {x = x_min_5, y = y_add_1},
        {x = x_min_4, y = y_add_1},
        {x = x_min_3, y = y_add_1},
        {x = x_min_2, y = y_add_1},
        {x = x_min_1, y = y_add_1},
        {x = x_0, y = y_add_1},
        {x = x_add_1, y = y_add_1},
        {x = x_add_2, y = y_add_1},
        {x = x_add_3, y = y_add_1},
        {x = x_add_4, y = y_add_1},
        {x = x_add_5, y = y_add_1},
        {x = x_add_6, y = y_add_1},
        {x = x_add_7, y = y_add_1},
        {x = x_add_8, y = y_add_1},
        {x = x_min_8, y = y_add_2},
        {x = x_min_7, y = y_add_2},
        {x = x_min_6, y = y_add_2},
        {x = x_min_5, y = y_add_2},
        {x = x_min_4, y = y_add_2},
        {x = x_min_3, y = y_add_2},
        {x = x_min_2, y = y_add_2},
        {x = x_min_1, y = y_add_2},
        {x = x_0, y = y_add_2},
        {x = x_add_1, y = y_add_2},
        {x = x_add_2, y = y_add_2},
        {x = x_add_3, y = y_add_2},
        {x = x_add_4, y = y_add_2},
        {x = x_add_5, y = y_add_2},
        {x = x_add_6, y = y_add_2},
        {x = x_add_7, y = y_add_2},
        {x = x_add_8, y = y_add_2},
        {x = x_min_8, y = y_add_3},
        {x = x_min_7, y = y_add_3},
        {x = x_min_6, y = y_add_3},
        {x = x_min_5, y = y_add_3},
        {x = x_min_4, y = y_add_3},
        {x = x_min_3, y = y_add_3},
        {x = x_min_2, y = y_add_3},
        {x = x_min_1, y = y_add_3},
        {x = x_0, y = y_add_3},
        {x = x_add_1, y = y_add_3},
        {x = x_add_2, y = y_add_3},
        {x = x_add_3, y = y_add_3},
        {x = x_add_4, y = y_add_3},
        {x = x_add_5, y = y_add_3},
        {x = x_add_6, y = y_add_3},
        {x = x_add_7, y = y_add_3},
        {x = x_add_8, y = y_add_3},
        {x = x_min_8, y = y_add_4},
        {x = x_min_7, y = y_add_4},
        {x = x_min_6, y = y_add_4},
        {x = x_min_5, y = y_add_4},
        {x = x_min_4, y = y_add_4},
        {x = x_min_3, y = y_add_4},
        {x = x_min_2, y = y_add_4},
        {x = x_min_1, y = y_add_4},
        {x = x_0, y = y_add_4},
        {x = x_add_1, y = y_add_4},
        {x = x_add_2, y = y_add_4},
        {x = x_add_3, y = y_add_4},
        {x = x_add_4, y = y_add_4},
        {x = x_add_5, y = y_add_4},
        {x = x_add_6, y = y_add_4},
        {x = x_add_7, y = y_add_4},
        {x = x_add_8, y = y_add_4},
        {x = x_min_8, y = y_add_5},
        {x = x_min_7, y = y_add_5},
        {x = x_min_6, y = y_add_5},
        {x = x_min_5, y = y_add_5},
        {x = x_min_4, y = y_add_5},
        {x = x_min_3, y = y_add_5},
        {x = x_min_2, y = y_add_5},
        {x = x_min_1, y = y_add_5},
        {x = x_0, y = y_add_5},
        {x = x_add_1, y = y_add_5},
        {x = x_add_2, y = y_add_5},
        {x = x_add_3, y = y_add_5},
        {x = x_add_4, y = y_add_5},
        {x = x_add_5, y = y_add_5},
        {x = x_add_6, y = y_add_5},
        {x = x_add_7, y = y_add_5},
        {x = x_add_8, y = y_add_5},
        {x = x_min_8, y = y_add_6},
        {x = x_min_7, y = y_add_6},
        {x = x_min_6, y = y_add_6},
        {x = x_min_5, y = y_add_6},
        {x = x_min_4, y = y_add_6},
        {x = x_min_3, y = y_add_6},
        {x = x_min_2, y = y_add_6},
        {x = x_min_1, y = y_add_6},
        {x = x_0, y = y_add_6},
        {x = x_add_1, y = y_add_6},
        {x = x_add_2, y = y_add_6},
        {x = x_add_3, y = y_add_6},
        {x = x_add_4, y = y_add_6},
        {x = x_add_5, y = y_add_6},
        {x = x_add_6, y = y_add_6},
        {x = x_add_7, y = y_add_6},
        {x = x_add_8, y = y_add_6},
        {x = x_min_8, y = y_add_7},
        {x = x_min_7, y = y_add_7},
        {x = x_min_6, y = y_add_7},
        {x = x_min_5, y = y_add_7},
        {x = x_min_4, y = y_add_7},
        {x = x_min_3, y = y_add_7},
        {x = x_min_2, y = y_add_7},
        {x = x_min_1, y = y_add_7},
        {x = x_0, y = y_add_7},
        {x = x_add_1, y = y_add_7},
        {x = x_add_2, y = y_add_7},
        {x = x_add_3, y = y_add_7},
        {x = x_add_4, y = y_add_7},
        {x = x_add_5, y = y_add_7},
        {x = x_add_6, y = y_add_7},
        {x = x_add_7, y = y_add_7},
        {x = x_add_8, y = y_add_7},
        {x = x_min_8, y = y_add_8},
        {x = x_min_7, y = y_add_8},
        {x = x_min_6, y = y_add_8},
        {x = x_min_5, y = y_add_8},
        {x = x_min_4, y = y_add_8},
        {x = x_min_3, y = y_add_8},
        {x = x_min_2, y = y_add_8},
        {x = x_min_1, y = y_add_8},
        {x = x_0, y = y_add_8},
        {x = x_add_1, y = y_add_8},
        {x = x_add_2, y = y_add_8},
        {x = x_add_3, y = y_add_8},
        {x = x_add_4, y = y_add_8},
        {x = x_add_5, y = y_add_8},
        {x = x_add_6, y = y_add_8},
        {x = x_add_7, y = y_add_8},
        {x = x_add_8, y = y_add_8},
    }
    return quads
end

local function get_area_of_quad(quad_position)
    local area = {
        left_top = quad_position,
        right_bottom = {
            x = quad_position.x + 16,
            y = quad_position.y + 16,
        }
    }
    return area
end

---@param event NthTickEventData
local function on_nth_tick(event)

    local time_to_live = 60 * 20
    local draw_rectangles = false
    global.quads_with_lights_by_uuid = global.quads_with_lights_by_uuid or {}
    local quads_with_lights_by_uuid = global.quads_with_lights_by_uuid
    global.quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid or {}
    local quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid
    -- global.quad_positions = global.quad_positions or {}
    -- local quad_positions = global.quad_positions

    local insert = table.insert
    local random = math.random
    -- local concat = table.concat
    local format = string.format
    local floor = math.floor
    -- local bxor = bit32.bxor
    -- local lshift = bit32.lshift

    for uuid, data in pairs(quads_with_lights_by_uuid) do
        -- local expire_tick = data.expire_tick
        -- if expire_tick <= event.tick then
    -- global.from_key = table.for_n_of(quads_with_lights_by_uuid, global.from_key, 170, function(data, uuid)
        if data.expire_tick <= event.tick then
            global.quads_with_lights_by_uuid[uuid] = nil
            -- return nil, true
        end
    end

    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local surface_index = surface.index
        local player_index = player.index
        local player_position = player.position
        local player_surface_key = player_index .. "_" .. surface_index
        local scale_and_intensity = light_scale_and_intensity[player.mod_settings["glow_aura_scale"].value]
        local quad_positions = get_surrounding_quad_positions(player_position)
        -- if not global.from_keys then global.from_keys = {} end
        -- global.from_keys[player_index] = table.for_n_of(quad_positions, global.from_keys[player_index], 88, function(quad_position)
            for _, quad_position in pairs(quad_positions) do
                local quad_uuid = format("%s, %d, %d", player_surface_key, quad_position.x, quad_position.y)
                -- local quad_uuid = unique_id(quad_position, player_surface_key, format)
                -- local quad_uuid = unique_id(quad_position, surface_index, player_index, bxor, lshift)
                -- local quad_uuid = unique_id(quad_position, surface_index, format)
                -- local quad_uuid = unique_id(quad_position, surface.index, concat)
                if draw_rectangles then
                    rendering.draw_text{
                        text = quad_uuid,
                        surface = surface,
                        target = quad_position,
                        target_offset = {0, -1},
                        color = {r = 1, g = 0, b = 0, a = 1},
                        time_to_live = 30,
                        scale = 3,
                    }
                end
                if quads_with_lights_by_uuid[quad_uuid] then
                    if quads_with_lights_by_uuid[quad_uuid].expire_tick < event.tick + 60 then
                        local light = quads_with_lights_by_uuid[quad_uuid].light
                        local modifier = random(-120, 120)
                        rendering.set_time_to_live(light, time_to_live + modifier)
                        quads_with_lights_by_uuid[quad_uuid].expire_tick = event.tick + time_to_live + modifier
                        if draw_rectangles then
                            local area = get_area_of_quad(quad_position)
                            rendering.draw_rectangle{
                                color = {r = 0, g = 0, b = 1, a = 1},
                                filled = false,
                                left_top = area.left_top,
                                right_bottom = area.right_bottom,
                                surface = surface,
                                time_to_live = 60,
                            }
                            rendering.draw_text{
                                text = quad_uuid,
                                surface = surface,
                                target = quad_position,
                                time_to_live = 60,
                                color = {r = 0.5, g = 0.5, b = 0.5, a = 0.5},
                            }
                        end
                    end
                else
                    local quad_with_no_trees = quads_with_no_trees_by_uuid[quad_uuid]
                    if not quad_with_no_trees or (quad_with_no_trees.expire_tick < event.tick) then
                        -- if not area then area = get_area_of_quad(quad_position) end
                        local area = get_area_of_quad(quad_position)
                        local trees = surface.find_entities_filtered{
                            area = area,
                            type = "tree",
                        }
                        local number_of_trees = #trees
                        if number_of_trees > 0 then
                            if draw_rectangles then
                                rendering.draw_rectangle{
                                    color = {r = 1, g = 1, b = 1, a = 1},
                                    filled = false,
                                    left_top = area.left_top,
                                    right_bottom = area.right_bottom,
                                    surface = surface,
                                    time_to_live = 60,
                                }
                            end
                            local tree_positions = {}
                            for _, tree in pairs(trees) do
                                insert(tree_positions, tree.position)
                            end
                            local average_tree_position = average_position(tree_positions)
                            local modified_time_to_live = time_to_live + random(-120, 120)
                            local light = rendering.draw_light{
                                sprite = "utility/light_medium",
                                scale = scale_and_intensity.scale,
                                intensity = scale_and_intensity.intensity + number_of_trees / 1000,
                                -- color = rainbow_color(number_of_trees * 4),
                                color = rainbow_color(average_tree_color_index(trees) * 8),
                                target = average_tree_position,
                                surface = surface,
                                time_to_live = modified_time_to_live,
                                players = {player},
                            }
                            quads_with_lights_by_uuid[quad_uuid] = {
                                expire_tick = event.tick + modified_time_to_live,
                                light = light,
                            }
                        else
                            quads_with_no_trees_by_uuid[quad_uuid] = {
                                expire_tick = event.tick + floor((time_to_live + random(-120, 120)) * 1.5),
                            }
                            if draw_rectangles then
                                rendering.draw_rectangle{
                                    color = {r = 0, g = 1, b = 0, a = 1},
                                    filled = false,
                                    left_top = area.left_top,
                                    right_bottom = area.right_bottom,
                                    surface = surface,
                                    time_to_live = 60,
                                }
                            end
                        end
                    end
                end
            -- end
        end
    end
end

local function mod_settings_changed(event)
    rendering.clear("glowing_trees")
    global.quads_with_lights_by_uuid = {}
end

script.on_nth_tick(20, on_nth_tick)

script.on_event(defines.events.on_runtime_mod_setting_changed, mod_settings_changed)