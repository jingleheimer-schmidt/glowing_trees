
require("util")

local glow_scales = {
    ["Tiny"] = 3,
    ["Small"] = 5,
    ["Medium"] = 7,
    ["Default"] = 9,
    ["Large"] = 11,
    ["Huge"] = 13,
    ["Enormous"] = 15,
}

local glow_chance_percents = {
    ["None"] = 0,
    ["Some"] = 0.25,
    ["Half"] = 0.5,
    ["Most"] = 0.75,
    ["All"] = 1,
}

local scale = glow_scales[settings.startup["glow_aura_scale"].value]
-- local leaves_enabled = settings.startup["glowing_trees_leaves"].value
-- local aura_enabled = settings.startup["glowing_trees_aura"].value
local glow_leaves_chance = glow_chance_percents[settings.startup["glowing_leaves_chance"].value]
local glow_aura_haze_chance = glow_chance_percents[settings.startup["glow_aura_haze_chance"].value]
local glow_aura_light_chance = glow_chance_percents[settings.startup["glow_aura_light_chance"].value]

local light_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1_25%.png",
    -- width = 205,
    -- height = 207,
    width = 51,
    height = 52,
    scale = scale + scale / 3,
    frame_count = 1,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1_25%.png",
    -- width = 205,
    -- height = 207,
    width = 51,
    height = 52,
    scale = scale,
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

local function draw_as_light_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_light = true
        end
        if animation.hr_version then
            animation.hr_version.draw_as_light = true
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_light_recursive(layer)
        end
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

local function draw_as_shadow_recursive(animation)
    if not animation.layers then
        if not (animation.draw_as_shadow or animation.draw_as_light or animation.draw_as_glow) then
            animation.draw_as_shadow = true
            if animation.hr_version then
                animation.hr_version.draw_as_shadow = true
            end
        end
    else
        for _, layer in pairs(animation.layers) do
            draw_as_shadow_recursive(layer)
        end
    end
end

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            local light = table.deepcopy(light_animation_small_1)
            local sprite = table.deepcopy(sprite_animation_small_1)

            local original_frame_count = get_frame_count(variation.leaves)
            local original_repeat_count = get_repeat_count(variation.leaves) or 1
            local new_repeat_count = original_frame_count * original_repeat_count
            light.repeat_count = new_repeat_count
            sprite.repeat_count = new_repeat_count

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
