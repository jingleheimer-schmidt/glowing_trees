
-- local table = require("__flib__.table")

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
    -- local speed = 0.01
    local speed = 1
    local r = math.sin(anchor * speed + 0) * 127 + 128
    local g = math.sin(anchor * speed + 2) * 127 + 128
    local b = math.sin(anchor * speed + 4) * 127 + 128
    return {r = r, g = g, b = b, a = 0.5}
end

local function temperature_color(temperature)
    local r = math.sin(temperature / 10000 + 0) * 127 + 128
    local g = math.sin(temperature / 10000 + 2) * 127 + 128
    local b = math.sin(temperature / 10000 + 4) * 127 + 128
    return {r = r, g = g, b = b, a = 0.5}
end

local function unique_id(position, player_surface_key, format)
    return format("%d, %d, %d", player_surface_key, position.x, position.y)
end

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

local function get_surrounding_chunk_positions(position, steps, step_length)
    local chunk_position = {
        x = math.floor(position.x / step_length),
        y = math.floor(position.y / step_length),
    }
    local chunk_positions = {}
    for x = chunk_position.x - steps, chunk_position.x + steps do
        for y = chunk_position.y - steps, chunk_position.y + steps do
            table.insert(chunk_positions, {x = x * step_length, y = y * step_length})
        end
    end
    return chunk_positions
end

local function get_area_of_quad(quad_position, quad_size)
    local area = {
        left_top = quad_position,
        right_bottom = {
            x = quad_position.x + quad_size,
            y = quad_position.y + quad_size,
        }
    }
    return area
end

local function get_middle_of_quad(quad_position, quad_size)
    local middle = {
        x = quad_position.x + quad_size / 2,
        y = quad_position.y + quad_size / 2,
    }
    return middle
end

local function draw_rectangle(surface, area, color)
    rendering.draw_rectangle{
        color = color,
        filled = false,
        left_top = area.left_top,
        right_bottom = area.right_bottom,
        surface = surface,
        time_to_live = 60,
    }
end

local function draw_text(surface, position, text, color, scale)
    rendering.draw_text{
        color = color,
        text = text,
        surface = surface,
        target = position,
        time_to_live = 60 * 20,
        scale = scale,
    }
end

local function average_tree_stage_index(trees)
    local tree_stage_index = 0
    for _, tree in pairs(trees) do
        tree_stage_index = tree_stage_index + tree.tree_stage_index
    end
    return tree_stage_index / #trees
end

local function normalize_value(value, min, max)
    return (value - min) / (max - min)
end

---@param event NthTickEventData
local function on_nth_tick(event)
    local time_to_live = 60 * 20
    local step_length = 8 * 4
    local steps = 128 / step_length
    local draw_rectangles = false
    global.quads_with_lights_by_uuid = global.quads_with_lights_by_uuid or {}
    local quads_with_lights_by_uuid = global.quads_with_lights_by_uuid
    global.quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid or {}
    local quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid
    local insert = table.insert
    local random = math.random
    local format = string.format
    local floor = math.floor
    local sin = math.sin
    local cos = math.cos
    for uuid, quad_data in pairs(quads_with_lights_by_uuid) do
        local expire_tick = quad_data.expire_tick
        if expire_tick <= event.tick then
            quads_with_lights_by_uuid[uuid] = nil
        end
    end
    for uuid, quad_data in pairs(quads_with_no_trees_by_uuid) do
        local expire_tick = quad_data.expire_tick
        if expire_tick <= event.tick then
            quads_with_no_trees_by_uuid[uuid] = nil
        end
    end
    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local surface_index = surface.index
        local player_index = player.index
        local player_position = player.position
        local player_surface_key = player_index .. "_" .. surface_index
        local scale_and_intensity = light_scale_and_intensity[player.mod_settings["glow_aura_scale"].value]
        -- local quad_positions = get_surrounding_quad_positions(player_position)
        local quad_positions = get_surrounding_chunk_positions(player_position, steps, step_length)
        for _, quad_position in pairs(quad_positions) do
            local quad_uuid = format("%s, %d, %d", player_surface_key, quad_position.x, quad_position.y)
            if draw_rectangles then
                draw_text(surface, quad_position, quad_uuid, {r = 1, g = 0, b = 0, a = 1}, 3)
            end
            local x = quad_position.x
            local y = quad_position.y
            local quad_has_existing_light = false
            local quad_has_no_trees = false
            local quad_data = nil
            if quads_with_lights_by_uuid and quads_with_lights_by_uuid[quad_uuid] then
                quad_has_existing_light = true
                quad_data = quads_with_lights_by_uuid[quad_uuid]
            end
            if quads_with_no_trees_by_uuid and quads_with_no_trees_by_uuid[quad_uuid] then
                quad_has_no_trees = true
                quad_data = quads_with_no_trees_by_uuid[quad_uuid]
            end
            local quad_is_new = not quad_has_existing_light and not quad_has_no_trees
            local quad_with_light_needs_update = quad_has_existing_light and (quad_data.expire_tick < event.tick + 60)
            local quad_with_no_trees_needs_update = quad_has_no_trees and (quad_data.expire_tick < event.tick + 60)
            if quad_with_light_needs_update then
                if quad_data.expire_tick < event.tick + 60 then
                    local modified_time_to_live = time_to_live + random(1, 120)
                    rendering.set_time_to_live(quad_data.light, modified_time_to_live)
                    quads_with_no_trees_by_uuid[quad_uuid] = nil
                    quads_with_lights_by_uuid[quad_uuid].expire_tick = event.tick + modified_time_to_live
                    if draw_rectangles then
                        draw_rectangle(surface, get_area_of_quad(quad_position, step_length), {r = 0, g = 0, b = 1, a = 1})
                    end
                end
            elseif quad_with_no_trees_needs_update or quad_is_new then
                local area = get_area_of_quad(quad_position, step_length)
                local trees = surface.find_entities_filtered{
                    area = area,
                    type = "tree",
                }
                local number_of_trees = #trees
                -- local number_of_trees = surface.count_entities_filtered{
                --     position = get_middle_of_quad(quad_position, step_length),
                --     radius = step_length * 0.55,
                --     type = "tree",
                -- }
                if number_of_trees > 0 then
                    -- local tree_positions = {}
                    -- for _, tree in pairs(trees) do
                    --     insert(tree_positions, tree.position)
                    -- end
                    -- local average_tree_position = average_position(tree_positions)
                    local average_tree_position = get_middle_of_quad(quad_position, step_length)
                    local modified_time_to_live = time_to_live + random(1, 120)
                    -- local anchor = (x ^ 2 + y ^ 2) * 0.0001
                    local anchor = surface.calculate_tile_properties({"temperature"}, {average_tree_position})["temperature"][1] / 1
                    local light = rendering.draw_light{
                        sprite = "utility/light_medium",
                        scale = scale_and_intensity.scale,
                        -- intensity = scale_and_intensity.intensity + number_of_trees / (1024 / step_length),
                        intensity = scale_and_intensity.intensity + number_of_trees / 50,
                        -- color = rainbow_color((number_of_trees / (1024 / step_length)) / 1000),
                        -- color = rainbow_color(average_tree_color_index(trees) * 8),
                        -- color = rainbow_color(average_tree_stage_index(trees) * 8),
                        -- color = rainbow_color((sin(x * 0.25) + cos(y * 0.25))),
                        color = rainbow_color(number_of_trees / 50),
                        -- color = rainbow_color((x + y) * 0.25),
                        -- color = rainbow_color(anchor),
                        -- color = temperature_color(anchor),
                        target = average_tree_position,
                        surface = surface,
                        time_to_live = modified_time_to_live,
                        players = {player},
                    }
                    quads_with_no_trees_by_uuid[quad_uuid] = nil
                    quads_with_lights_by_uuid[quad_uuid] = {
                        expire_tick = event.tick + modified_time_to_live,
                        light = light,
                    }
                    if draw_rectangles then
                        draw_rectangle(surface, area, {r = 1, g = 1, b = 1, a = 1})
                        draw_text(surface, average_tree_position, number_of_trees, {r = 1, g = 1, b = 1, a = 1}, 10)
                    end
                else
                    quads_with_lights_by_uuid[quad_uuid] = nil
                    quads_with_no_trees_by_uuid[quad_uuid] = {
                        expire_tick = event.tick + floor((time_to_live + random(1, 120)) * 1.5),
                    }
                    if draw_rectangles then
                        draw_rectangle(surface, area, {r = 0, g = 1, b = 0, a = 1})
                    end
                end
            end
        end
    end
end

local function mod_settings_changed(event)
    -- global.quads_with_lights = {}
    -- global.quads_with_no_trees = {}
    global.quads_with_lights_by_uuid = {}
    global.quads_with_no_trees_by_uuid = {}
    rendering.clear("glowing_trees")
end

script.on_nth_tick(10, on_nth_tick)

script.on_event(defines.events.on_runtime_mod_setting_changed, mod_settings_changed)
