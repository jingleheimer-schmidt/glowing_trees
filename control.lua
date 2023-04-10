
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

-- local floor = math.floor
-- local insert = table.insert
-- local random = math.random

---@param event EventData.on_chunk_charted
local function render_glows(event)
    local surface_index = event.surface_index
    local area = event.area
    local force = event.force
    local time_to_live = 60 * 33
    local leaves_chance = glow_chance_percents[settings.startup["glowing_leaves_chance"].value]
    -- local aura_haze_chance = glow_chance_percents[settings.startup["glow_aura_haze_chance"].value]
    -- local aura_light_chance = glow_chance_percents[settings.startup["glow_aura_light_chance"].value]
    local aura_haze_chance = 1 / time_to_live
    local aura_light_chance = 1 / time_to_live
    -- local glow_scale = glow_scales[settings.startup["glow_aura_scale"].value]
    local glow_scale = 20
    local surface = game.get_surface(surface_index)
    if not surface then return end
    local trees = surface.find_entities_filtered{
        area = area,
        type = "tree",
    }
    for _, tree in pairs(trees) do
        if aura_haze_chance >= math.random() then
            rendering.draw_sprite{
                sprite = "utility/light_medium",
                target = tree,
                surface = tree.surface,
                forces = {force},
                x_scale = glow_scale,
                y_scale = glow_scale,
                render_layer = "decorative",
                -- tint = {r = .1, g = .1, b = .1, a = 0.125},
                time_to_live = time_to_live,
            }
        end
        if aura_light_chance >= math.random() then
            rendering.draw_light{
                sprite = "utility/light_medium",
                target = tree,
                surface = tree.surface,
                forces = {force},
                scale = glow_scale,
                render_layer = "decorative",
                -- color = {r = .1, g = .1, b = .1, a = 0.25},
                time_to_live = time_to_live,
            }
        end
    end
end

---@param position MapPosition
---@return ChunkPosition
local function get_chunk_position(position)
    return {
        x = math.floor(position.x / 32),
        y = math.floor(position.y / 32),
    }
end

---@param position MapPosition
---@param steps integer
---@return ChunkPosition[]
local function get_surrounding_chunk_positions(position, steps)
    local positions = {}
    local chunk_position = get_chunk_position(position)
    for x = -steps, steps do
        for y = -steps, steps do
            table.insert(positions, {
                x = (chunk_position.x + x),
                y = (chunk_position.y + y),
            })
        end
    end
    return positions
end

---@param chunk_position ChunkPosition
---@return BoundingBox
local function get_area_of_chunk(chunk_position)
    return {
        left_top = {
            x = chunk_position.x * 32,
            y = chunk_position.y * 32,
        },
        right_bottom = {
            x = (chunk_position.x + 1) * 32,
            y = (chunk_position.y + 1) * 32,
        },
    }
end

local function name_of_random_tree()
    local prototypes = game.entity_prototypes
    local tree_names = {}
    for name, prototype in pairs(prototypes) do
        if prototype.type == "tree" then
            table.insert(tree_names, name)
        end
    end
    return tree_names[math.random(1, #tree_names)]
end

-- local function rainbow_color(tick, uuid)
--     local speed = 0.01
--     local r = math.sin(tick * speed + uuid) * 127 + 128
--     local g = math.sin(tick * speed + uuid + 2) * 127 + 128
--     local b = math.sin(tick * speed + uuid + 4) * 127 + 128
--     return {r = r, g = g, b = b, a = 0.5}
-- end

local function rainbow_color(tick)
    local speed = 0.01
    local r = math.sin(tick * speed + 0) * 127 + 128
    local g = math.sin(tick * speed + 2) * 127 + 128
    local b = math.sin(tick * speed + 4) * 127 + 128
    return {r = r, g = g, b = b, a = 0.5}
end

-- local function unique_id(position)
--     local x = position.x
--     local y = position.y
--     local uniqueId = bit32.bor(bit32.lshift(x, 64), y)
--     return uniqueId
-- end

-- ---@param position MapPosition
-- ---@param surface_name string
-- ---@return string
-- local function unique_id(position, surface_name)
--     local x = position.x
--     local y = position.y
--     return surface_name .. " " .. x .. " " .. y
-- end

local function unique_id(position, surface_index)
    local temp_table = {position.x, position.y, surface_index}
    local uuid = table.concat(temp_table, ", ")
    return uuid
end

-- ---@param position MapPosition
-- ---@param surface_index uint
-- ---@return integer
-- local function unique_id(position, surface_index)
--     local x = math.floor(position.x)
--     local y = math.floor(position.y)
--     -- local hash1 = bit32.band(x,y)
--     -- local hash2 = bit32.band(hash1, surface_index)

--     local hash = bit32.bor(bit32.lshift(surface_index, 20), bit32.lshift(x, 10), y)
--     return hash
-- end

local function distance(position1, position2)
    local x = position1.x - position2.x
    local y = position1.y - position2.y
    return math.sqrt(x * x + y * y)
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

---@param chunk_position ChunkPosition
---@return MapPosition
local function chunk_to_map_position(chunk_position)
    return {
        x = chunk_position.x * 32,
        y = chunk_position.y * 32,
    }
end

local function divide_chunk_into_quads(chunk_position)

    local x = chunk_position.x * 32
    local y = chunk_position.y * 32
    local quad_positions = {
        {x = x, y = y},
        {x = x + 16, y = y},
        {x = x, y = y + 16},
        {x = x + 16, y = y + 16},
    }
    -- table.insert(quad_positions, {x = x, y = y})
    -- table.insert(quad_positions, {x = x + 16, y = y})
    -- table.insert(quad_positions, {x = x, y = y + 16})
    -- table.insert(quad_positions, {x = x + 16, y = y + 16})
    return quad_positions
end

-- local function get_surrounding_quad_positions(position, steps, step_length)
--     local quads = {}
--     step_length = step_length or 16
--     local floor = math.floor
--     local insert = table.insert
--     for x = -steps, steps, 1 do
--         for y = -steps, steps, 1 do
--             insert(quads, {
--                 x = (floor(position.x / step_length) + x) * step_length,
--                 y = (floor(position.y / step_length) + y) * step_length,
--             })
--             -- quads[#quads + 1] = {
--             --     x = (floor(position.x / step_length) + x) * step_length,
--             --     y = (floor(position.y / step_length) + y) * step_length,
--             -- }
--         end
--     end
--     return quads
-- end
local function get_surrounding_quad_positions(position, steps, step_length)
    local quads = {}
    step_length = step_length or 16
    local floor = math.floor
    -- local insert = table.insert
    local pos_x = floor(position.x / step_length) * step_length
    local pos_y = floor(position.y / step_length) * step_length
    local range = steps * step_length
    local count = 1
    for x = -range, range, step_length do
        for y = -range, range, step_length do
            -- insert(quads, {
            --     x = pos_x + x,
            --     y = pos_y + y,
            -- })
            quads[count] = {
                x = pos_x + x,
                y = pos_y + y,
            }
            count = count + 1
        end
    end
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

    local time_to_live = 60 * 30
    global.quads_with_lights_by_uuid = global.quads_with_lights_by_uuid or {}
    local quads_with_lights_by_uuid = global.quads_with_lights_by_uuid
    global.quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid or {}
    local quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid

    local floor = math.floor
    local insert = table.insert
    local random = math.random

    for uuid, data in pairs(quads_with_lights_by_uuid) do
        local expire_tick = data.expire_tick
        if expire_tick <= event.tick then
            global.quads_with_lights_by_uuid[uuid] = nil
        end
    end

    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local player_position = player.position
        local scale_and_intensity = light_scale_and_intensity[player.mod_settings["glow_aura_scale"].value]
        -- local chunk_positions = get_surrounding_chunk_positions(player_position, 4)
        local quad_positions = get_surrounding_quad_positions(player_position, 8)
        -- for _, chunk_position in pairs(chunk_positions) do
        --     for _, quad_position in pairs(divide_chunk_into_quads(chunk_position)) do
        for _, quad_position in pairs(quad_positions) do
                local quad_uuid = unique_id(quad_position, surface.index)
                local draw_rectangles = false
                local area = nil
                if draw_rectangles then
                    area = get_area_of_quad(quad_position)
                end

                if quads_with_lights_by_uuid[quad_uuid] then
                    if quads_with_lights_by_uuid[quad_uuid].expire_tick < event.tick + 30 then
                        local light = quads_with_lights_by_uuid[quad_uuid].light
                        local modifier = random(-300, 300)
                        rendering.set_time_to_live(light, time_to_live + modifier)
                        quads_with_lights_by_uuid[quad_uuid].expire_tick = event.tick + time_to_live + modifier
                        if draw_rectangles then
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
                    if not quads_with_no_trees_by_uuid[quad_uuid] or (quads_with_no_trees_by_uuid[quad_uuid].expire_tick < event.tick) then
                        if not area then area = get_area_of_quad(quad_position) end
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
                            local modified_time_to_live = time_to_live + random(-300, 300)
                            local light = rendering.draw_light{
                                sprite = "utility/light_medium",
                                scale = scale_and_intensity.scale,
                                intensity = scale_and_intensity.intensity + number_of_trees / 1000,
                                color = rainbow_color(number_of_trees * 5),
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
                                expire_tick = event.tick + (time_to_live + random(-300, 300)) * 2,
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

-- script.on_event(defines.events.on_chunk_charted, render_glows)

script.on_nth_tick(5, on_nth_tick)

script.on_event(defines.events.on_runtime_mod_setting_changed, mod_settings_changed)