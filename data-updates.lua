
require("util")

local glow_animation_light = {
    filename = "__glowing_trees__/glow_3_5%.png",
    width = 820,
    height = 826,
    scale = 0.6,
    frame_count = 3,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local glow_animation_glow = {
    filename = "__glowing_trees__/glow_3_25%.png",
    width = 820,
    height = 826,
    scale = 0.4,
    frame_count = 3,
    draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local glow_animation_small = {
    filename = "__glowing_trees__/small_pngs/glow_3_1%.png",
    width = 205,
    height = 207,
    scale = 5,
    frame_count = 3,
    draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local light_animation_small = {
    filename = "__glowing_trees__/small_pngs/glow_3_5%.png",
    width = 205,
    height = 207,
    scale = 4,
    frame_count = 3,
    draw_as_light = true,
    -- blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small = {
    filename = "__glowing_trees__/small_pngs/glow_3_1%.png",
    width = 205,
    height = 207,
    scale = 3.5,
    frame_count = 3,
    -- draw_as_glow = true,
    -- blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            if variation.overlay then
                local animation = util.table.deepcopy(variation.overlay)
                variation.overlay = {
                    layers = {
                        animation,
                        sprite_animation_small,
                        light_animation_small
                    }
                }
            else
                variation.overlay = {
                    layers = {
                        sprite_animation_small,
                        light_animation_small
                    }
                }
            end
        end
    end
end
