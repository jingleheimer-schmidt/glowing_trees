
require("util")

local glow_animation_light = {
    filename = "__glowing_trees__/glow_3_5%.png",
    width = 820,
    height = 826,
    scale = 3/4,
    frame_count = 3,
    draw_as_light = true,
    blend_mode = "additive-soft"
}

local glow_animation_glow = {
    filename = "__glowing_trees__/glow_3_25%.png",
    width = 820,
    height = 826,
    scale = 0.5,
    frame_count = 3,
    draw_as_glow = true,
    blend_mode = "additive-soft",
    apply_runtime_tint = true
}

for _, tree in pairs(data.raw.tree) do
    if tree.variations then
        for _, variation in pairs(tree.variations) do
            if variation.overlay then
                local animation = util.table.deepcopy(variation.overlay)
                variation.overlay = {
                    animation,
                    glow_animation_glow
                }
            else
                variation.overlay = glow_animation_glow
            end
        end
    end
end
