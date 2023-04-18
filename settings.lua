
local glow_leaves_chance = {
    type = "string-setting",
    name = "glowing_leaves_chance",
    setting_type = "startup",
    default_value = "Most",
    allowed_values = {
        "None",
        "Few",
        "Some",
        "Half",
        "Most",
        "All",
    },
    order = "a-1"
}

local glow_decoratives_chance = {
    type = "string-setting",
    name = "glowing_decoratives_chance",
    setting_type = "startup",
    default_value = "Few",
    allowed_values = {
        "None",
        "Few",
        "Some",
        "Half",
        "Most",
        "All",
    },
    order = "a-1"
}

-- local glow_aura_haze_chance = {
--     type = "string-setting",
--     name = "glow_aura_haze_chance",
--     setting_type = "startup",
--     default_value = "Few",
--     allowed_values = {
--         "None",
--         "Few",
--         "Some",
--         "Half",
--         "Most",
--         "All",
--     },
--     order = "b-1"
-- }

-- local glow_aura_light_chance = {
--     type = "string-setting",
--     name = "glow_aura_light_chance",
--     setting_type = "startup",
--     default_value = "Some",
--     allowed_values = {
--         "None",
--         "Few",
--         "Some",
--         "Half",
--         "Most",
--         "All",
--     },
--     order = "b-2"
-- }

-- local glow_scale = {
--     type = "string-setting",
--     name = "glow_aura_scale",
--     setting_type = "startup",
--     default_value = "Large",
--     allowed_values = {
--         "Tiny",
--         "Small",
--         "Medium",
--         "Large",
--         "Huge",
--         "Enormous",
--     },
--     order = "b-3"
-- }

data:extend({
    glow_leaves_chance,
    glow_decoratives_chance,
    -- glow_aura_haze_chance,
    -- glow_aura_light_chance,
    -- glow_scale,
})

local glow_scale = {
    type = "string-setting",
    name = "glow_aura_scale",
    setting_type = "runtime-per-user",
    default_value = "Medium",
    allowed_values = {
        "Tiny",
        "Small",
        "Medium",
        "Large",
        "Huge",
        "Enormous",
    },
    order = "a-1"
}

local color_mode = {
    type = "string-setting",
    name = "glow_aura_color_mode",
    setting_type = "runtime-per-user",
    default_value = "biome plus density",
    allowed_values = {
        "surrounding biome",
        "tree density",
        "biome plus density",
        "horizontal rainbow stripes",
        "vertical rainbow stripes",
        "diagonal rainbow stripes",
        "lissajous rainbow",
    },
    order = "a-1"
}

data:extend({
    glow_scale,
    color_mode,
})