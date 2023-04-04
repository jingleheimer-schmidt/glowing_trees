require("util")


local function add_glow(animation)
    if animation.layers then
        for _, layer in pairs(animation.layers) do
            add_glow(layer)
        end
    else

        local original_layers = util.table.deepcopy(animation.layers)
        -- local new_layer = util.table.deepcopy(animation.layers)

    end
end

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


local explosion_animation = {
    {
        filename = "__base__/graphics/entity/lab/lab-light.png",
        blend_mode = "additive",
        draw_as_light = true,
        width = 106,
        height = 100,
        frame_count = 33,
        line_length = 11,
        animation_speed = 1 / 3,
        shift = util.by_pixel(-1, 1),
        hr_version =
        {
            filename = "__base__/graphics/entity/lab/hr-lab-light.png",
            blend_mode = "additive",
            draw_as_light = true,
            width = 216,
            height = 194,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 0),
            scale = 0.5
        }
    },
    {
        filename = "__base__/graphics/entity/medium-explosion/medium-explosion-1.png",
        draw_as_glow = true,
        priority = "high",
        width = 62,
        height = 112,
        frame_count = 30,
        line_length = 6,
        shift = util.by_pixel(-1, -36),
        animation_speed = 0.5,
        hr_version =
        {
        filename = "__base__/graphics/entity/medium-explosion/hr-medium-explosion-1.png",
        draw_as_glow = true,
        priority = "high",
        width = 124,
        height = 224,
        frame_count = 30,
        line_length = 6,
        shift = util.by_pixel(-1, -36),
        animation_speed = 0.5,
        scale = 0.5
        }
    },
    {
        filename = "__base__/graphics/entity/medium-explosion/medium-explosion-2.png",
        draw_as_glow = true,
        priority = "high",
        width = 78,
        height = 106,
        frame_count = 41,
        line_length = 6,
        shift = util.by_pixel(-13,-34),
        animation_speed = 0.5,
        hr_version =
        {
        filename = "__base__/graphics/entity/medium-explosion/hr-medium-explosion-2.png",
        draw_as_glow = true,
        priority = "high",
        width = 154,
        height = 212,
        frame_count = 41,
        line_length = 6,
        shift = util.by_pixel(-13,-34),
        animation_speed = 0.5,
        scale = 0.5
        }
    },
    {
        filename = "__base__/graphics/entity/medium-explosion/medium-explosion-3.png",
        draw_as_glow = true,
        priority = "high",
        width = 64,
        height = 118,
        frame_count = 39,
        line_length = 6,
        shift = util.by_pixel(1,-37),
        animation_speed = 0.5,
        hr_version =
        {
        filename = "__base__/graphics/entity/medium-explosion/hr-medium-explosion-3.png",
        draw_as_glow = true,
        priority = "high",
        width = 126,
        height = 236,
        frame_count = 39,
        line_length = 6,
        shift = util.by_pixel(0.5,-37),
        animation_speed = 0.5,
        scale = 0.5
        }
    }
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
