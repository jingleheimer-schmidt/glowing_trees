
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

---@param position MapPosition
---@param surface_name string
---@return string
local function unique_id(position, surface_name)
    local x = position.x
    local y = position.y
    return tostring(surface_name) .. " " .. tostring(x) .. " " .. tostring(y)
end

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
    local quad_positions = {}
    local x = chunk_position.x * 32
    local y = chunk_position.y * 32
    table.insert(quad_positions, {x = x, y = y})
    table.insert(quad_positions, {x = x + 16, y = y})
    table.insert(quad_positions, {x = x, y = y + 16})
    table.insert(quad_positions, {x = x + 16, y = y + 16})
    return quad_positions
end

local function get_area_of_quad(quad_position)
    return {
        left_top = quad_position,
        right_bottom = {
            x = quad_position.x + 16,
            y = quad_position.y + 16,
        },
    }
end

---spawn a flying text in every chunk within a radius of 4 chunks from the player
---@param event NthTickEventData
local function on_nth_tick(event)

    local time_to_live = 60 * 60
    -- local leaves_chance = glow_chance_percents[settings.startup["glowing_leaves_chance"].value]
    -- local aura_haze_chance = glow_chance_percents[settings.startup["glow_aura_haze_chance"].value]
    -- local aura_light_chance = glow_chance_percents[settings.startup["glow_aura_light_chance"].value]
    local aura_haze_chance = 1 / time_to_live
    -- local aura_light_chance = 1 / time_to_live
    local aura_light_chance = 1 / 100
    -- local glow_scale = glow_scales[settings.startup["glow_aura_scale"].value]
    local glow_scale = 5

    -- global.lights = global.lights or {}
    -- local lights = global.lights
    -- global.trees_with_lights_by_uuid = global.trees_with_lights_by_uuid or {}
    -- local trees_with_lights_by_uuid = global.trees_with_lights_by_uuid
    -- global.chunks_with_lights_by_uuid = global.chunks_with_lights_by_uuid or {}
    -- local chunks_with_lights_by_uuid = global.chunks_with_lights_by_uuid
    global.quads_with_lights_by_uuid = global.quads_with_lights_by_uuid or {}
    local quads_with_lights_by_uuid = global.quads_with_lights_by_uuid
    global.quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid or {}
    local quads_with_no_trees_by_uuid = global.quads_with_no_trees_by_uuid

    for uuid, data in pairs(quads_with_lights_by_uuid) do
        local expire_tick = data.expire_tick
        if expire_tick <= event.tick then
            global.quads_with_lights_by_uuid[uuid] = nil
        end
    end

    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local player_position = player.position
        local force = player.force
        local scale_and_intensity = light_scale_and_intensity[player.mod_settings["glow_aura_scale"].value]
        local chunk_positions = get_surrounding_chunk_positions(player_position, 4)
        for _, chunk_position in pairs(chunk_positions) do
            for _, quad_position in pairs(divide_chunk_into_quads(chunk_position)) do
                local quad_uuid = unique_id(quad_position, surface.name)
                local area = get_area_of_quad(quad_position)

                local draw_rectangles = true

                if quads_with_lights_by_uuid[quad_uuid] then
                    if quads_with_lights_by_uuid[quad_uuid].expire_tick < event.tick + 30 then
                        local light = quads_with_lights_by_uuid[quad_uuid].light
                        rendering.set_time_to_live(light, time_to_live)
                        quads_with_lights_by_uuid[quad_uuid].expire_tick = event.tick + time_to_live
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
                                table.insert(tree_positions, tree.position)
                            end
                            local average_tree_position = average_position(tree_positions)
                            local light = rendering.draw_light{
                                sprite = "utility/light_medium",
                                -- scale = glow_scale,
                                -- scale = 5,
                                scale = scale_and_intensity.scale,
                                -- scale = #trees / 10,
                                -- intensity = 0.1 + number_of_trees / 500,
                                intensity = scale_and_intensity.intensity + number_of_trees / 1000,
                                -- intensity = #trees / 75,
                                -- minimum_darkness = 0.3,
                                color = rainbow_color(number_of_trees * 4),
                                target = average_tree_position,
                                surface = surface,
                                time_to_live = time_to_live,
                                players = {player},
                            }
                            quads_with_lights_by_uuid[quad_uuid] = {
                                expire_tick = event.tick + time_to_live,
                                light = light,
                            }
                        else
                            quads_with_no_trees_by_uuid[quad_uuid] = {
                                expire_tick = event.tick + time_to_live * 2,
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
            end
            -- if not chunks_with_lights_by_uuid[chunk_uuid] then
            --     -- local area = get_area_of_chunk(get_chunk_position(chunk_position))
            --     local trees = surface.find_entities_filtered{
            --         area = area,
            --         type = "tree",
            --     }
            --     if #trees > 0 then
            --         local tree_positions = {}
            --         for _, tree in pairs(trees) do
            --             table.insert(tree_positions, tree.position)
            --         end
            --         local average_tree_position = average_position(tree_positions)
            --         local light = rendering.draw_light{
            --             sprite = "utility/light_medium",
            --             scale = glow_scale,
            --             -- scale = #trees / 10,
            --             intensity = 0.5,
            --             -- minimum_darkness = 0.3,
            --             color = rainbow_color(event.tick, chunk_uuid),
            --             target = average_tree_position,
            --             surface = surface,
            --             time_to_live = time_to_live,
            --             forces = {force},
            --         }
            --         global.chunks_with_lights_by_uuid[chunk_uuid] = {
            --             expire_tick = event.tick + time_to_live,
            --             position = average_tree_position,
            --             light = light,
            --         }
            --     end
            -- end
            -- local random = math.random()
            -- if aura_light_chance >= random then
            --     local area = get_area_of_chunk(get_chunk_position(chunk_position))
            --     local trees = surface.find_entities_filtered{
            --         area = area,
            --         type = "tree",
            --     }
            --     for _, tree in pairs(trees) do
            --         random = math.random()
            --         if aura_light_chance >= random then goto continue end
            --         -- local lights = global.lights or {}
            --         -- global.render_queue = global.render_queue or {}
            --         local tree_position = tree.position
            --         -- local trees_with_lights_by_uuid = global.trees_with_lights_by_uuid or {}
            --         local uuid = unique_id(tree_position)
            --         -- if trees_with_lights_by_uuid[uuid] then goto continue end
            --         local tree_has_light = trees_with_lights_by_uuid[uuid]
            --         local distance_check = true
            --         rendering.draw_text{
            --             text = "•",
            --             surface = tree.surface,
            --             target = tree,
            --             forces = {force},
            --             scale = 1,
            --             -- render_layer = "decorative",
            --             color = {r = 1, g = 1, b = 1, a = 1},
            --             time_to_live = 5,
            --         }
            --         for id, data in pairs(lights) do
            --             if tree_has_light or (not data.position) or (distance(tree_position, data.position) < 15) then
            --                 distance_check = false
            --                 if data.expire_tick < game.tick then
            --                     global.lights[id] = nil
            --                     global.trees_with_lights_by_uuid[uuid] = nil
            --                 end
            --             end
            --         end
            --         if not distance_check then goto continue end
            --         local light = rendering.draw_light{
            --             -- sprite = "tree_glow",
            --             sprite = "utility/light_medium",
            --             target = tree,
            --             surface = tree.surface,
            --             forces = {force},
            --             scale = glow_scale,
            --             render_layer = "decorative",
            --             -- color = {r = .1, g = .1, b = .1, a = 0.25},
            --             -- color = rainbow_color(game.tick, unique_id(tree.position)),
            --             color = rainbow_color(game.tick, tree.tree_color_index),
            --             time_to_live = time_to_live,
            --             intensity = 1 / 5,
            --         }
            --         -- global.lights = global.lights or {}
            --         global.lights[light] = {
            --             surface = tree.surface.name,
            --             position = tree_position,
            --             expire_tick = game.tick + time_to_live,
            --         }
            --         global.trees_with_lights_by_uuid[uuid] = true
            --         ::continue::
            --     end
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