
require("util")

local tree_glow = {
    type = "sprite",
    name = "tree_glow",
    filename = "__glowing_trees__/glow.png",
    priority = "high",
    width = 820,
    height = 826,
    scale = 1/11,
}

data:extend({
    tree_glow
})

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
            -- if variation.leaves then
            --     local animation = variation.leaves
            --     if animation.layers then
            --         -- local original_layers = util.table.deepcopy(animation.layers)
            --         -- local new_layer = util.table.deepcopy(animation.layers)
            --         -- new_layer.
            --         -- animation.layers = {
            --         --     original_layers,
            --         --     new_layer
            --         -- }
            --     else
            --         local original_animation = util.table.deepcopy(animation)
            --         local glow_layer = util.table.deepcopy(animation)
            --         local light_layer = util.table.deepcopy(animation)
            --         if not (glow_layer.draw_as_shadow or glow_layer.draw_as_glow or glow_layer.draw_as_light) then
            --             glow_layer.draw_as_glow = true
            --             light_layer.draw_as_light = true
            --             -- explosion_animation[1].frame_count = original_animation.frame_count
            --             -- glow_animation.frame_count = original_animation.frame_count
            --             variation.leaves.layers = {
            --                 original_animation,
            --                 -- light_layer,
            --                 -- glow_layer
            --                 -- explosion_animation[1]
            --                 glow_animation_glow,
            --                 -- glow_animation_light,
            --             }
            --         end
            --         log(serpent.block(tree.variations[_].leaves))
            --     end
            -- end
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
    -- elseif tree.pictures then
    --     local pictures = tree.pictures
    --     if pictures.layers then
    --         -- local glow_layer = util.table.deepcopy(pictures.layers)
    --     else
    --         local glow_layer = util.table.deepcopy(pictures)
    --         if not (glow_layer.draw_as_shadow or glow_layer.draw_as_glow or glow_layer.draw_as_light) then
    --             glow_layer.draw_as_light = true
    --             tree.pictures.layers = {
    --                 pictures,
    --                 glow_layer
    --             }
    --         end
    --     end
    end
end
