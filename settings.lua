
local glow_leaves_chance = {
    type = "string-setting",
    name = "glowing_leaves_chance",
    setting_type = "startup",
    default_value = "most",
    allowed_values = {
        "none",
        "few",
        "some",
        "half",
        "most",
        "all",
    },
    order = "a-1"
}

local glow_decoratives_chance = {
    type = "string-setting",
    name = "glowing_decoratives_chance",
    setting_type = "startup",
    default_value = "few",
    allowed_values = {
        "none",
        "few",
        "some",
        "half",
        "most",
        "all",
    },
    order = "a-2"
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
    default_value = "sync",
    allowed_values = {
        "sync",
        "tiny",
        "small",
        "medium",
        "large",
        "huge",
        "enormous",
    },
    order = "a-2"
}

local color_mode = {
    type = "string-setting",
    name = "glow_aura_color_mode",
    setting_type = "runtime-per-user",
    default_value = "sync",
    allowed_values = {
        "sync",
        "none",
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

local brightness = {
    type = "string-setting",
    name = "glow_aura_brightness",
    setting_type = "runtime-per-user",
    default_value = "sync",
    allowed_values = {
        "sync",
        "minimum",
        "very low",
        "low",
        "medium",
        "high",
        "very high",
        "maximum",
    },
    order = "a-3"
}

local step_count = {
    type = "string-setting",
    name = "glow_aura_step_count",
    setting_type = "runtime-per-user",
    default_value = "sync",
    allowed_values = {
        "sync",
        "small",
        "medium",
        "large",
        "huge",
    },
    order = "a-4"
}

data:extend({
    glow_scale,
    color_mode,
    brightness,
    step_count,
})

local global_glow_scale = {
    type = "string-setting",
    name = "global_glow_aura_scale",
    setting_type = "runtime-global",
    default_value = "large",
    allowed_values = {
        "tiny",
        "small",
        "medium",
        "large",
        "huge",
        "enormous",
    },
    order = "a-2"
}

local global_color_mode = {
    type = "string-setting",
    name = "global_glow_aura_color_mode",
    setting_type = "runtime-global",
    default_value = "surrounding biome",
    allowed_values = {
        "none",
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

local global_brightness = {
    type = "string-setting",
    name = "global_glow_aura_brightness",
    setting_type = "runtime-global",
    default_value = "medium",
    allowed_values = {
        "minimum",
        "very low",
        "low",
        "medium",
        "high",
        "very high",
        "maximum",
    },
    order = "a-3"
}

local global_step_count = {
    type = "string-setting",
    name = "global_glow_aura_step_count",
    setting_type = "runtime-global",
    default_value = "medium",
    allowed_values = {
        "small",
        "medium",
        "large",
        "huge",
    },
    order = "a-4"
}

data:extend({
    global_glow_scale,
    global_color_mode,
    global_brightness,
    global_step_count,
})