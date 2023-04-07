
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
local leaves_enabled = settings.startup["glowing_trees_leaves"].value
local aura_enabled = settings.startup["glowing_trees_aura"].value

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
            -- if variation.leaves.layers then
            --     original_frame_count = variation.leaves.layers[1].frame_count
            --     original_repeat_count = variation.leaves.layers[1].repeat_count or 1
            -- end
            local new_repeat_count = original_frame_count * original_repeat_count
            light.repeat_count = new_repeat_count
            sprite.repeat_count = new_repeat_count

            if leaves_enabled then
                if variation.leaves then
                    -- local glowing_leaves = util.table.deepcopy(variation.leaves)
                    -- -- draw_as_light_recursive(glowing_leaves)
                    -- draw_as_glow_recursive(glowing_leaves)
                    -- -- if glowing_leaves.layers then
                    -- --     for _, layer in pairs(glowing_leaves) do
                    -- --         layer.draw_as_light = true
                    -- --     end
                    -- -- else
                    -- --     glowing_leaves.draw_as_light = true
                    -- -- end
                    -- local original_leaves = util.table.deepcopy(variation.leaves)
                    -- variation.leaves = {
                    --     layers = {
                    --         glowing_leaves,
                    --         original_leaves,
                    --     }
                    -- }
                    draw_as_glow_recursive(variation.leaves)
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
                            -- glowing_leaves
                        }
                    }
                else
                    variation.overlay = {
                        layers = {
                            light,
                            sprite,
                            -- glowing_leaves
                        }
                    }
                end
            end
        end
    end
end
