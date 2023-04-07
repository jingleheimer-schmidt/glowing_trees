
require("util")

local glow_scales = {
    ["None"] = 0,
    ["Miniscule"] = 0.25,
    ["Tiny"] = 0.5,
    ["Small"] = 0.75,
    ["Medium"] = 1,
    ["Default"] = 1.5,
    ["Large"] = 2,
    ["Huge"] = 3,
    ["Enormous"] = 5,
}

local scale = glow_scales[settings.startup["glowing_trees_scale"].value]

local light_animation_small_1 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_1/glow_1_25%.png",
    width = 205,
    height = 207,
    scale = scale + scale / 3,
    frame_count = 1,
    draw_as_light = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

local sprite_animation_small_1 = {
    filename = "__glowing_trees__/source_media/small_pngs/frame_count_1/glow_1_5%.png",
    width = 205,
    height = 207,
    scale = scale,
    frame_count = 1,
    -- draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true,
}

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            local light = table.deepcopy(light_animation_small_1)
            local sprite = table.deepcopy(sprite_animation_small_1)
            local original_frame_count = variation.leaves.frame_count
            local original_repeat_count = variation.leaves.repeat_count or 1
            if variation.leaves.layers then
                original_frame_count = variation.leaves.layers[1].frame_count
                original_repeat_count = variation.leaves.layers[1].repeat_count or 1
            end
            local new_repeat_count = original_frame_count * original_repeat_count
            light.repeat_count = new_repeat_count
            sprite.repeat_count = new_repeat_count
            if variation.overlay then
                local animation = util.table.deepcopy(variation.overlay)
                variation.overlay = {
                    layers = {
                        animation,
                        light,
                        sprite
                    }
                }
            else
                variation.overlay = {
                    layers = {
                        light,
                        sprite
                    }
                }
            end
        end
    end
end
