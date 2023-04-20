
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
local glow_aura_haze_chance = 0
local glow_aura_light_chance = 0

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

local function get_frame_count(animation)
    if not animation.layers then
        return animation.frame_count
    else
        return get_frame_count(animation.layers[1])
    end
end

local function get_repeat_count(animation)
    if not animation.layers then
        return animation.repeat_count
    else
        return get_repeat_count(animation.layers[1])
    end
end

local function draw_as_glow_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_glow = true
            if animation.hr_version then
                animation.hr_version.draw_as_glow = true
            end
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_glow_recursive(layer)
        end
    end
end

local function set_animation_scale_recursive(animation, multiplier)
    if not animation.layers then
        animation.scale = (animation.scale or 1) * multiplier
        if animation.hr_version then
            animation.hr_version.scale = (animation.scale or 1) * multiplier
        end
    else
        for _, layer in pairs(animation.layers) do
            set_animation_scale_recursive(layer)
        end
    end
end

local function draw_as_light_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_light = true
            if animation.hr_version then
                animation.hr_version.draw_as_light = true
            end
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_light_recursive(layer)
        end
    end
end

local function enable_runtime_tint_recursive(animation)
    if not animation.layers then
        animation.apply_runtime_tint = true
        if animation.hr_version then
            animation.hr_version.apply_runtime_tint = true
        end
    else
        for _, layer in pairs(animation.layers) do
            enable_runtime_tint_recursive(layer)
        end
    end
end

local function set_tint_recursive(animation, color)
    if not animation.layers then
        animation.tint = color
        if animation.hr_version then
            animation.hr_version.tint = color
        end
    else
        for _, layer in pairs(animation.layers) do
            set_tint_recursive(layer, color)
        end
    end
end

local function divide_color(color, divisor)
    return {r = color.r / divisor, g = color.g / divisor, b = color.b / divisor, a = color.a}
end

local function modify_shift(animation, x_modifier, y_modifier)
    if not animation.layers then
        animation.shift = {animation.shift[1] + x_modifier, animation.shift[2] + y_modifier}
        if animation.hr_version then
            animation.hr_version.shift = {animation.hr_version.shift[1] + x_modifier, animation.hr_version.shift[2] + y_modifier}
        end
    else
        for _, layer in pairs(animation.layers) do
            modify_shift(layer, x_modifier, y_modifier)
        end
    end
end

local function set_repeat_count_recursive(animation, repeat_count)
    if not animation.layers then
        animation.repeat_count = repeat_count
        if animation.hr_version then
            animation.hr_version.repeat_count = repeat_count
        end
    else
        for _, layer in pairs(animation.layers) do
            set_repeat_count_recursive(layer, repeat_count)
        end
    end
end

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            -- local light = table.deepcopy(light_animation_small_1)
            -- local sprite = table.deepcopy(sprite_animation_small_1)
            local light = util.table.deepcopy(variation.leaves)
            local sprite = util.table.deepcopy(variation.leaves)

            local scale_modifier = 5
            -- local color = {r = 1, g = 1, b = 1, a = 0}
            local color = tree.colors[math.random(1, #tree.colors)]
            -- color.a = 0
            -- local color = {r = .1, g = .1, b = .1, a = 0.5}
            color = divide_color(color, 10)
            set_animation_scale_recursive(light, scale_modifier)
            set_animation_scale_recursive(sprite, scale_modifier)
            draw_as_light_recursive(light)
            draw_as_light_recursive(sprite)
            -- enable_runtime_tint_recursive(light)
            -- enable_runtime_tint_recursive(sprite)
            set_tint_recursive(light, color)
            set_tint_recursive(sprite, color)
            -- modify_shift(light, 0, 1)
            -- modify_shift(sprite, 0, 1)

            local original_frame_count = get_frame_count(variation.leaves)
            local original_repeat_count = get_repeat_count(variation.leaves) or 1
            local new_repeat_count = original_frame_count * original_repeat_count
            -- light.repeat_count = new_repeat_count
            -- sprite.repeat_count = new_repeat_count
            -- set_repeat_count_recursive(light, new_repeat_count)
            -- set_repeat_count_recursive(sprite, new_repeat_count)

            if glow_leaves_chance >= math.random() then
                if variation.leaves then
                    draw_as_glow_recursive(variation.leaves)
                end
            end

            local glow_overlay_layers = {
                layers = {}
            }
            if variation.overlay then
                local animation = util.table.deepcopy(variation.overlay)
                table.insert(glow_overlay_layers.layers, animation)
            end
            if glow_aura_light_chance >= math.random() then
                table.insert(glow_overlay_layers.layers, light)
            end
            if glow_aura_haze_chance >= math.random() then
                table.insert(glow_overlay_layers.layers, sprite)
            end
            if glow_overlay_layers.layers[1] then
                variation.overlay = glow_overlay_layers
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