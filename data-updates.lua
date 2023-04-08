
require("util")

local glow_scales = {
    ["Tiny"] = 1,
    ["Small"] = 3,
    ["Medium"] = 4,
    ["Default"] = 5,
    ["Large"] = 6,
    ["Huge"] = 7,
    ["Enormous"] = 10,
}

local scale = glow_scales[settings.startup["glowing_trees_scale"].value]
local leaves_enabled = settings.startup["glowing_trees_leaves"].value
local aura_enabled = settings.startup["glowing_trees_aura"].value

local light_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1_5%.png",
    -- width = 205,
    -- height = 207,
    width = 51,
    height = 52,
    scale = (scale + scale / 3) * 4,
    frame_count = 1,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small_1 = {
    filename = "__glowing_trees__/source_media/tiny_pngs/frame_count_1/glow_1_5%.png",
    -- width = 205,
    -- height = 207,
    width = 51,
    height = 52,
    scale = scale * 4,
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
        animation.draw_as_light = true
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

            if leaves_enabled then
                if variation.leaves then
                    draw_as_glow_recursive(variation.leaves)
                    -- draw_as_light_recursive(variation.leaves)
                end
            end

            if aura_enabled then
                if variation.overlay then
                    local animation = util.table.deepcopy(variation.overlay)
                    variation.overlay = {
                        layers = {
                            animation,
                            light,
                            sprite,
                        }
                    }
                else
                    variation.overlay = {
                        layers = {
                            light,
                            sprite,
                        }
                    }
                end
            end
        end
    end
end
