
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
local function get_chunk_position(position)
    return {
        x = math.floor(position.x / 32),
        y = math.floor(position.y / 32),
    }
end

---@param position MapPosition
---@param steps integer
---@return table
local function get_surrounding_chunk_positions(position, steps)
    local positions = {}
    local chunk_position = get_chunk_position(position)
    for x = -steps, steps do
        for y = -steps, steps do
            table.insert(positions, {
                x = (chunk_position.x + x) * 32,
                y = (chunk_position.y + y) * 32,
            })
        end
    end
    return positions
end

---@param chunk_position ChunkPosition
---@return table
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

local function rainbow_color(tick, uuid)
    local speed = 0.01
    local r = math.sin(tick * speed + uuid) * 127 + 128
    local g = math.sin(tick * speed + uuid + 2) * 127 + 128
    local b = math.sin(tick * speed + uuid + 4) * 127 + 128
    return {r = r, g = g, b = b, a = 0.5}
end

local function unique_id(position)
    local x = position.x
    local y = position.y
    local uniqueId = bit32.bor(bit32.lshift(x, 16), y)
    return uniqueId
end

local function distance(position1, position2)
    local x = position1.x - position2.x
    local y = position1.y - position2.y
    return math.sqrt(x * x + y * y)
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
    local glow_scale = 10

    global.lights = global.lights or {}
    local lights = global.lights
    global.trees_with_lights_by_uuid = global.trees_with_lights_by_uuid or {}
    local trees_with_lights_by_uuid = global.trees_with_lights_by_uuid
    global.chunks_with_lights_by_uuid = global.chunks_with_lights_by_uuid or {}
    local chunks_with_lights_by_uuid = global.chunks_with_lights_by_uuid

    for _, player in pairs(game.connected_players) do
        local surface = player.surface
        local player_position = player.position
        local force = player.force
        local chunk_positions = get_surrounding_chunk_positions(player_position, 3)
        for _, chunk_position in pairs(chunk_positions) do
                        -- for _, tree in pairs(trees) do
            --     if aura_light_chance >= math.random() then
            local chunk_uuid = unique_id(chunk_position)
            local random = math.random()
            if aura_light_chance >= random then
                local area = get_area_of_chunk(get_chunk_position(chunk_position))
                local trees = surface.find_entities_filtered{
                    area = area,
                    type = "tree",
                }
                for _, tree in pairs(trees) do
                    random = math.random()
                    if aura_light_chance >= random then goto continue end
                    -- local lights = global.lights or {}
                    -- global.render_queue = global.render_queue or {}
                    local tree_position = tree.position
                    -- local trees_with_lights_by_uuid = global.trees_with_lights_by_uuid or {}
                    local uuid = unique_id(tree_position)
                    -- if trees_with_lights_by_uuid[uuid] then goto continue end
                    local tree_has_light = trees_with_lights_by_uuid[uuid]
                    local distance_check = true
                    rendering.draw_text{
                        text = "•",
                        surface = tree.surface,
                        target = tree,
                        forces = {force},
                        scale = 1,
                        -- render_layer = "decorative",
                        color = {r = 1, g = 1, b = 1, a = 1},
                        time_to_live = 5,
                    }
                    for id, data in pairs(lights) do
                        if tree_has_light or (not data.position) or (distance(tree_position, data.position) < 15) then
                            distance_check = false
                            if data.expire_tick < game.tick then
                                global.lights[id] = nil
                                global.trees_with_lights_by_uuid[uuid] = nil
                            end
                        end
                    end
                    if not distance_check then goto continue end
                    local light = rendering.draw_light{
                        -- sprite = "tree_glow",
                        sprite = "utility/light_medium",
                        target = tree,
                        surface = tree.surface,
                        forces = {force},
                        scale = glow_scale,
                        render_layer = "decorative",
                        -- color = {r = .1, g = .1, b = .1, a = 0.25},
                        -- color = rainbow_color(game.tick, unique_id(tree.position)),
                        color = rainbow_color(game.tick, tree.tree_color_index),
                        time_to_live = time_to_live,
                        intensity = 1 / 5,
                    }
                    -- global.lights = global.lights or {}
                    global.lights[light] = {
                        surface = tree.surface.name,
                        position = tree_position,
                        expire_tick = game.tick + time_to_live,
                    }
                    global.trees_with_lights_by_uuid[uuid] = true
                    ::continue::
                end
            end
        end
    end
end

-- script.on_event(defines.events.on_chunk_charted, render_glows)

script.on_nth_tick(5, on_nth_tick)