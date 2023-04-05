
require("util")

local light_animation_small_3 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_3/glow_3_25%.png",
    width = 205,
    height = 207,
    scale = 2.25,
    frame_count = 3,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small_3 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_3/glow_3_5%.png",
    width = 205,
    height = 207,
    scale = 1.75,
    frame_count = 3,
    -- draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local light_animation_small_1 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_1/glow_1_25%.png",
    width = 205,
    height = 207,
    scale = 2.25,
    frame_count = 1,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small_1 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_1/glow_1_5%.png",
    width = 205,
    height = 207,
    scale = 1.75,
    frame_count = 1,
    -- draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprites_by_frame_count = {
    [1] = sprite_animation_small_1,
    [2] = nil,
    [3] = sprite_animation_small_3,
}

local lights_by_frame_count = {
    [1] = light_animation_small_1,
    [2] = nil,
    [3] = light_animation_small_3,
}

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            local frame_count = variation.leaves.frame_count or variation.leaves.layers[1].frame_count
            if variation.overlay then
                local animation = util.table.deepcopy(variation.overlay)
                variation.overlay = {
                    layers = {
                        animation,
                        sprites_by_frame_count[frame_count],
                        lights_by_frame_count[frame_count]
                    }
                }
            else
                variation.overlay = {
                    layers = {
                        sprites_by_frame_count[frame_count],
                        lights_by_frame_count[frame_count]
                    }
                }
            end
        end
    end
end
