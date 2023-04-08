
local glow_scale = {
    type = "string-setting",
    name = "glowing_trees_scale",
    setting_type = "startup",
    default_value = "Default",
    allowed_values = {
        "Tiny",
        "Small",
        "Medium",
        "Default",
        "Large",
        "Huge",
        "Enormous",
    },
    order = "a"
}

local glow_aura = {
    type = "bool-setting",
    name = "glowing_trees_aura",
    setting_type = "startup",
    default_value = true,
}

local glow_leaves = {
    type = "bool-setting",
    name = "glowing_trees_leaves",
    setting_type = "startup",
    default_value = true,
}

data:extend({
    glow_scale,
    glow_aura,
    glow_leaves,
})