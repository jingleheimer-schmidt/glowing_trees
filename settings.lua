
local glow_scale = {
    type = "string-setting",
    name = "glowing_trees_scale",
    setting_type = "startup",
    default_value = "Default",
    allowed_values = {
        "None",
        "Miniscule",
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

data:extend({
    glow_scale,
})