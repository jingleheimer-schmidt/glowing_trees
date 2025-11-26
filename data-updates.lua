
require("util")

local glow_scales = {
    ["tiny"] = 4,
    ["small"] = 5,
    ["nedium"] = 6,
    ["large"] = 7,
    ["huge"] = 8,
    ["enormous"] = 9,
}

local glow_chance_percents = {
    ["none"] = 0,
    ["few"] = 0.125,
    ["some"] = 0.25,
    ["half"] = 0.5,
    ["most"] = 0.75,
    ["all"] = 1,
}

-- local scale = glow_scales[settings.startup["glow_aura_scale"].value]
local scale = 7
local glow_leaves_chance = glow_chance_percents[settings.startup["glowing_leaves_chance"].value]
local glow_decoratives_chance = glow_chance_percents[settings.startup["glowing_decoratives_chance"].value]
-- local glow_aura_haze_chance = glow_chance_percents[settings.startup["glow_aura_haze_chance"].value]
-- local glow_aura_light_chance = glow_chance_percents[settings.startup["glow_aura_light_chance"].value]
-- local glow_aura_haze_chance = 0
-- local glow_aura_light_chance = 0

local light_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1.png",
    width = 51,
    height = 52,
    scale = scale * 2,
    frame_count = 1,
    draw_as_light = true,
    blend_mode = "additive-soft",
    -- apply_runtime_tint = true,
    -- tint = {r = 1, g = 1, b = 1, a = 0.5},
}

local sprite_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1_5%.png",
    width = 51,
    height = 52,
    scale = scale * 2,
    frame_count = 1,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

---@param animation data.Animation
local function get_frame_count(animation)
    if not animation.layers then
        return animation.frame_count
    else
        return get_frame_count(animation.layers[1])
    end
end

---@param animation data.Animation
local function get_repeat_count(animation)
    if not animation.layers then
        return animation.repeat_count
    else
        return get_repeat_count(animation.layers[1])
    end
end

---@param animation data.Animation
local function draw_as_glow_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_glow = true
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_glow_recursive(layer)
        end
    end
end

---@param animation data.Animation
---@param multiplier number
local function set_animation_scale_recursive(animation, multiplier)
    if not animation.layers then
        animation.scale = (animation.scale or 1) * multiplier
    else
        for _, layer in pairs(animation.layers) do
            set_animation_scale_recursive(layer, multiplier)
        end
    end
end

---@param animation data.Animation
local function draw_as_light_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_light = true
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_light_recursive(layer)
        end
    end
end

---@param animation data.Animation
local function enable_runtime_tint_recursive(animation)
    if not animation.layers then
        animation.apply_runtime_tint = true
    else
        for _, layer in pairs(animation.layers) do
            enable_runtime_tint_recursive(layer)
        end
    end
end

---@param animation data.Animation
---@param color Color
local function set_tint_recursive(animation, color)
    if not animation.layers then
        animation.tint = color
    else
        for _, layer in pairs(animation.layers) do
            set_tint_recursive(layer, color)
        end
    end
end

---@param color Color
---@param divisor number
---@return Color
local function divide_color(color, divisor)
    return { r = color.r / divisor, g = color.g / divisor, b = color.b / divisor, a = color.a }
end

---@param animation data.Animation
---@param x_modifier number
---@param y_modifier number
local function modify_shift(animation, x_modifier, y_modifier)
    if not animation.layers then
        animation.shift = { animation.shift[1] + x_modifier, animation.shift[2] + y_modifier }
    else
        for _, layer in pairs(animation.layers) do
            modify_shift(layer, x_modifier, y_modifier)
        end
    end
end

---@param animation data.Animation
---@param repeat_count number
local function set_repeat_count_recursive(animation, repeat_count)
    if not animation.layers then
        animation.repeat_count = repeat_count
    else
        for _, layer in pairs(animation.layers) do
            set_repeat_count_recursive(layer, repeat_count)
        end
    end
end

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            if glow_leaves_chance >= math.random() then
                if variation.leaves then
                    draw_as_glow_recursive(variation.leaves)
                end
            end
        end
    end
end

for _, plant in pairs(data.raw["plant"]) do
    if plant.variations then
        for _, variation in pairs(plant.variations) do
            if glow_leaves_chance >= math.random() then
                if variation.leaves then
                    draw_as_glow_recursive(variation.leaves)
                end
            end
        end
    end
end

for _, decorative in pairs(data.raw["optimized-decorative"]) do
    for _, picture in pairs(decorative.pictures) do
        if glow_decoratives_chance >= math.random() then
            if glow_decoratives_chance == 1 or math.random(1, 2) == 1 then
                if not picture.draw_as_glow then
                    picture.draw_as_glow = true
                end
            end
        end
    end
end

for _, simulation in pairs(data.raw["utility-constants"]["default"]["main_menu_simulations"]) do
    simulation.mods = simulation.mods or {}
    table.insert(simulation.mods, "glowing_trees")
end
