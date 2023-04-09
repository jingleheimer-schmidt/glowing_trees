
local glow_leaves_chance = {
    type = "string-setting",
    name = "glowing_leaves_chance",
    setting_type = "startup",
    default_value = "All",
    allowed_values = {
        "None",
        "Some",
        "Half",
        "Most",
        "All",
    },
    order = "a-1"
}

local glow_aura_haze_chance = {
    type = "string-setting",
    name = "glow_aura_haze_chance",
    setting_type = "startup",
    default_value = "Most",
    allowed_values = {
        "None",
        "Some",
        "Half",
        "Most",
        "All",
    },
    order = "b-1"
}

local glow_aura_light_chance = {
    type = "string-setting",
    name = "glow_aura_light_chance",
    setting_type = "startup",
    default_value = "All",
    allowed_values = {
        "None",
        "Some",
        "Half",
        "Most",
        "All",
    },
    order = "b-2"
}

local glow_scale = {
    type = "string-setting",
    name = "glow_aura_scale",
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
    order = "b-3"
}

data:extend({
    glow_leaves_chance,
    glow_aura_haze_chance,
    glow_aura_light_chance,
    glow_scale,
})