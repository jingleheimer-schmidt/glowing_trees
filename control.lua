
local insert = table.insert
local random = math.random
local format = string.format
local floor = math.floor
local sin = math.sin
local cos = math.cos
local min = math.min
local max = math.max
local sqrt = math.sqrt

local light_scales = {
    ["sync"] = "sync",
    ["tiny"] = 4,
    ["small"] = 4.5,
    ["medium"] = 5,
    ["large"] = 6,
    ["huge"] = 7.5,
    ["enormous"] = 10,
}

local brightness = {
    ["sync"] = "sync",
    ["minimum"] = 0.05,
    ["very low"] = 0.1,
    ["low"] = 0.15,
    ["medium"] = 0.25,
    ["high"] = 0.4,
    ["very high"] = 0.6,
    ["maximum"] = 0.75,
}

local step_counts = {
    ["sync"] = "sync",
    ["small"] = 96,
    ["medium"] = 128,
    ["large"] = 192,
    ["huge"] = 256,
}

local function rgba_to_hsva(r, g, b, a)
    local maximum = max(r, g, b)
    local minimum = min(r, g, b)
    local h, s, v
    v = maximum
    local d = maximum - minimum
    if maximum == 0 then
        s = 0
    else
        s = d / maximum
    end
    if maximum == minimum then
        h = 0
    else
        if maximum == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif maximum == g then
            h = (b - r) / d + 2
        elseif maximum == b then
            h = (r - g) / d + 4
        end
        h = h * 60
    end
    return h, s, v, a
end

local function hsva_to_rgba(h, s, v, a)
    local r, g, b
    local i = floor(h / 60)
    local f = h / 60 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    else
        r, g, b = v, p, q
    end
    return r, g, b, a
end

local function normalize_color(color, brightness_value)
    local r, g, b, a, h, s, v = 0, 0, 0, 0, 0, 0, 0
    h, s, v, a = rgba_to_hsva(color.r, color.g, color.b, color.a)
    -- r, g, b, a = hsva_to_rgba(h, 0.9, 0.15, 1)
    r, g, b, a = hsva_to_rgba(h, 0.8, brightness_value, 1)
    return { r = r, g = g, b = b, a = a }
end

---@param x number
---@param y number
---@param anchor number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function rainbow_color(x, y, anchor, frequency, surface)
    frequency = frequency or 0.1
    local r = sin(anchor * frequency + 0) * 127 + 128
    local g = sin(anchor * frequency + 2) * 127 + 128
    local b = sin(anchor * frequency + 4) * 127 + 128
    return { r = r, g = g, b = b, a = 255 }
end

---@param x number
---@param y number
---@param anchor number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function diagonal_rainbow(x, y, anchor, frequency, surface)
    anchor = x + y
    return rainbow_color(x, y, anchor, frequency, surface)
end

---@param x number
---@param y number
---@param anchor number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function horizonal_rainbow(x, y, anchor, frequency, surface)
    anchor = y
    return rainbow_color(x, y, anchor, frequency, surface)
end

---@param x number
---@param y number
---@param anchor number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function vertical_rainbow(x, y, anchor, frequency, surface)
    anchor = x
    return rainbow_color(x, y, anchor, frequency, surface)
end

---@param x number
---@param y number
---@param anchor number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function lissajous_rainbow(x, y, anchor, frequency, surface)
    -- anchor = (sin(x) * cos(y)) * 10000
    -- anchor = sin(x) / sin(y)
    frequency = 0.01
    local choice = random(1, 3)
    local choices = {
        diagonal_rainbow,
        horizonal_rainbow,
        vertical_rainbow
    }
    return choices[choice](x, y, anchor, frequency, surface)
    -- return rainbow_color(x, y, anchor, frequency, surface)
end

---@param x number
---@param y number
---@param number_of_trees number
---@param frequency number
---@param surface LuaSurface
---@return Color
local function surrounding_biome_color(x, y, number_of_trees, frequency, surface)
    local map_color = surface.get_tile(x, y).prototype.map_color
    local hidden_tile = surface.get_hidden_tile { x, y }
    if hidden_tile then
        map_color = prototypes.tile[hidden_tile].map_color
    end
    -- return normalize_color(map_color)
    return map_color
end

local function tree_density_color(x, y, number_of_trees, frequency, surface)
    local anchor = number_of_trees * 2
    return rainbow_color(x, y, anchor, frequency, surface)
end

local function biome_plus_density(x, y, anchor, frequency, surface)
    local biome = surrounding_biome_color(x, y, anchor, frequency, surface)
    local density = tree_density_color(x, y, anchor, frequency, surface)
    local weight = 4
    return {
        r = (biome.r * weight + density.r) / (weight + 1),
        g = (biome.g * weight + density.g) / (weight + 1),
        b = (biome.b * weight + density.b) / (weight + 1),
        a = 255
    }
end

local function concentric_rainbow(x, y, anchor, frequency, surface)
    local distance_from_origin = sqrt(x * x + y * y)
    frequency = 0.025
    return rainbow_color(x, y, distance_from_origin, frequency, surface)
end

local color_modes = {
    ["surrounding biome"] = surrounding_biome_color,
    ["tree density"] = tree_density_color,
    ["lissajous rainbow"] = lissajous_rainbow,
    ["diagonal rainbow stripes"] = diagonal_rainbow,
    ["horizontal rainbow stripes"] = horizonal_rainbow,
    ["biome plus density"] = biome_plus_density,
    ["vertical rainbow stripes"] = vertical_rainbow,
    ["concentric rainbow circles"] = concentric_rainbow,
}

local function average_color(colors)
    local r, g, b, a = 0, 0, 0, 0
    for _, color in pairs(colors) do
        r = r + color.r
        g = g + color.g
        b = b + color.b
        a = a + color.a
    end
    return {
        r = r / #colors,
        g = g / #colors,
        b = b / #colors,
        -- a = a / #colors,
        a = 255,
    }
end

---@param positions MapPosition[]
---@return MapPosition
local function average_position(positions)
    local x = 0
    local y = 0
    for _, position in pairs(positions) do
        x = x + position.x
        y = y + position.y
    end
    return {
        x = x / #positions,
        y = y / #positions,
    }
end

local function average_tree_color_index(trees)
    local color_index = 0
    for _, tree in pairs(trees) do
        color_index = color_index + tree.tree_color_index
    end
    return math.floor(color_index / #trees)
end

local function get_surrounding_chunk_positions(position, steps, step_length)
    local pos_x = floor(position.x / step_length)
    local pos_y = floor(position.y / step_length)
    -- possible steps are: 96/16 = 6, 128/16 = 8, 192/16 = 12, 256/16 = 16
    local x_min_16 = (pos_x - 16) * step_length
    local y_min_16 = (pos_y - 16) * step_length
    local x_min_15 = (pos_x - 15) * step_length
    local y_min_15 = (pos_y - 15) * step_length
    local x_min_14 = (pos_x - 14) * step_length
    local y_min_14 = (pos_y - 14) * step_length
    local x_min_13 = (pos_x - 13) * step_length
    local y_min_13 = (pos_y - 13) * step_length
    local x_min_12 = (pos_x - 12) * step_length
    local y_min_12 = (pos_y - 12) * step_length
    local x_min_11 = (pos_x - 11) * step_length
    local y_min_11 = (pos_y - 11) * step_length
    local x_min_10 = (pos_x - 10) * step_length
    local y_min_10 = (pos_y - 10) * step_length
    local x_min_9 = (pos_x - 9) * step_length
    local y_min_9 = (pos_y - 9) * step_length
    local x_min_8 = (pos_x - 8) * step_length
    local y_min_8 = (pos_y - 8) * step_length
    local x_min_7 = (pos_x - 7) * step_length
    local y_min_7 = (pos_y - 7) * step_length
    local x_min_6 = (pos_x - 6) * step_length
    local y_min_6 = (pos_y - 6) * step_length
    local x_min_5 = (pos_x - 5) * step_length
    local y_min_5 = (pos_y - 5) * step_length
    local x_min_4 = (pos_x - 4) * step_length
    local y_min_4 = (pos_y - 4) * step_length
    local x_min_3 = (pos_x - 3) * step_length
    local y_min_3 = (pos_y - 3) * step_length
    local x_min_2 = (pos_x - 2) * step_length
    local y_min_2 = (pos_y - 2) * step_length
    local x_min_1 = (pos_x - 1) * step_length
    local y_min_1 = (pos_y - 1) * step_length
    -- local x_0 = (pos_x) * step_length
    -- local y_0 = (pos_y) * step_length
    local x_add_0 = (pos_x + 0) * step_length
    local y_add_0 = (pos_y + 0) * step_length
    local x_add_1 = (pos_x + 1) * step_length
    local y_add_1 = (pos_y + 1) * step_length
    local x_add_2 = (pos_x + 2) * step_length
    local y_add_2 = (pos_y + 2) * step_length
    local x_add_3 = (pos_x + 3) * step_length
    local y_add_3 = (pos_y + 3) * step_length
    local x_add_4 = (pos_x + 4) * step_length
    local y_add_4 = (pos_y + 4) * step_length
    local x_add_5 = (pos_x + 5) * step_length
    local y_add_5 = (pos_y + 5) * step_length
    local x_add_6 = (pos_x + 6) * step_length
    local y_add_6 = (pos_y + 6) * step_length
    local x_add_7 = (pos_x + 7) * step_length
    local y_add_7 = (pos_y + 7) * step_length
    local x_add_8 = (pos_x + 8) * step_length
    local y_add_8 = (pos_y + 8) * step_length
    local x_add_9 = (pos_x + 9) * step_length
    local y_add_9 = (pos_y + 9) * step_length
    local x_add_10 = (pos_x + 10) * step_length
    local y_add_10 = (pos_y + 10) * step_length
    local x_add_11 = (pos_x + 11) * step_length
    local y_add_11 = (pos_y + 11) * step_length
    local x_add_12 = (pos_x + 12) * step_length
    local y_add_12 = (pos_y + 12) * step_length
    local x_add_13 = (pos_x + 13) * step_length
    local y_add_13 = (pos_y + 13) * step_length
    local x_add_14 = (pos_x + 14) * step_length
    local y_add_14 = (pos_y + 14) * step_length
    local x_add_15 = (pos_x + 15) * step_length
    local y_add_15 = (pos_y + 15) * step_length
    local x_add_16 = (pos_x + 16) * step_length
    local y_add_16 = (pos_y + 16) * step_length
    if steps == 6 then
        return {
            { x = x_min_6, y = y_min_6 }, { x = x_min_5, y = y_min_6 }, { x = x_min_4, y = y_min_6 }, { x = x_min_3, y = y_min_6 }, { x = x_min_2, y = y_min_6 }, { x = x_min_1, y = y_min_6 }, { x = x_add_0, y = y_min_6 }, { x = x_add_1, y = y_min_6 }, { x = x_add_2, y = y_min_6 }, { x = x_add_3, y = y_min_6 }, { x = x_add_4, y = y_min_6 }, { x = x_add_5, y = y_min_6 }, { x = x_add_6, y = y_min_6 }, { x = x_min_6, y = y_min_5 }, { x = x_min_5, y = y_min_5 }, { x = x_min_4, y = y_min_5 }, { x = x_min_3, y = y_min_5 }, { x = x_min_2, y = y_min_5 }, { x = x_min_1, y = y_min_5 }, { x = x_add_0, y = y_min_5 }, { x = x_add_1, y = y_min_5 }, { x = x_add_2, y = y_min_5 }, { x = x_add_3, y = y_min_5 }, { x = x_add_4, y = y_min_5 }, { x = x_add_5, y = y_min_5 }, { x = x_add_6, y = y_min_5 }, { x = x_min_6, y = y_min_4 }, { x = x_min_5, y = y_min_4 }, { x = x_min_4, y = y_min_4 }, { x = x_min_3, y = y_min_4 }, { x = x_min_2, y = y_min_4 }, { x = x_min_1, y = y_min_4 }, { x = x_add_0, y = y_min_4 }, { x = x_add_1, y = y_min_4 }, { x = x_add_2, y = y_min_4 }, { x = x_add_3, y = y_min_4 }, { x = x_add_4, y = y_min_4 }, { x = x_add_5, y = y_min_4 }, { x = x_add_6, y = y_min_4 }, { x = x_min_6, y = y_min_3 }, { x = x_min_5, y = y_min_3 }, { x = x_min_4, y = y_min_3 }, { x = x_min_3, y = y_min_3 }, { x = x_min_2, y = y_min_3 }, { x = x_min_1, y = y_min_3 }, { x = x_add_0, y = y_min_3 }, { x = x_add_1, y = y_min_3 }, { x = x_add_2, y = y_min_3 }, { x = x_add_3, y = y_min_3 }, { x = x_add_4, y = y_min_3 }, { x = x_add_5, y = y_min_3 }, { x = x_add_6, y = y_min_3 }, { x = x_min_6, y = y_min_2 }, { x = x_min_5, y = y_min_2 }, { x = x_min_4, y = y_min_2 }, { x = x_min_3, y = y_min_2 }, { x = x_min_2, y = y_min_2 }, { x = x_min_1, y = y_min_2 }, { x = x_add_0, y = y_min_2 }, { x = x_add_1, y = y_min_2 }, { x = x_add_2, y = y_min_2 }, { x = x_add_3, y = y_min_2 }, { x = x_add_4, y = y_min_2 }, { x = x_add_5, y = y_min_2 }, { x = x_add_6, y = y_min_2 }, { x = x_min_6, y = y_min_1 }, { x = x_min_5, y = y_min_1 }, { x = x_min_4, y = y_min_1 }, { x = x_min_3, y = y_min_1 }, { x = x_min_2, y = y_min_1 }, { x = x_min_1, y = y_min_1 }, { x = x_add_0, y = y_min_1 }, { x = x_add_1, y = y_min_1 }, { x = x_add_2, y = y_min_1 }, { x = x_add_3, y = y_min_1 }, { x = x_add_4, y = y_min_1 }, { x = x_add_5, y = y_min_1 }, { x = x_add_6, y = y_min_1 }, { x = x_min_6, y = y_add_0 }, { x = x_min_5, y = y_add_0 }, { x = x_min_4, y = y_add_0 }, { x = x_min_3, y = y_add_0 }, { x = x_min_2, y = y_add_0 }, { x = x_min_1, y = y_add_0 }, { x = x_add_0, y = y_add_0 }, { x = x_add_1, y = y_add_0 }, { x = x_add_2, y = y_add_0 }, { x = x_add_3, y = y_add_0 }, { x = x_add_4, y = y_add_0 }, { x = x_add_5, y = y_add_0 }, { x = x_add_6, y = y_add_0 }, { x = x_min_6, y = y_add_1 }, { x = x_min_5, y = y_add_1 }, { x = x_min_4, y = y_add_1 }, { x = x_min_3, y = y_add_1 }, { x = x_min_2, y = y_add_1 }, { x = x_min_1, y = y_add_1 }, { x = x_add_0, y = y_add_1 }, { x = x_add_1, y = y_add_1 }, { x = x_add_2, y = y_add_1 }, { x = x_add_3, y = y_add_1 }, { x = x_add_4, y = y_add_1 }, { x = x_add_5, y = y_add_1 }, { x = x_add_6, y = y_add_1 }, { x = x_min_6, y = y_add_2 }, { x = x_min_5, y = y_add_2 }, { x = x_min_4, y = y_add_2 }, { x = x_min_3, y = y_add_2 }, { x = x_min_2, y = y_add_2 }, { x = x_min_1, y = y_add_2 }, { x = x_add_0, y = y_add_2 }, { x = x_add_1, y = y_add_2 }, { x = x_add_2, y = y_add_2 }, { x = x_add_3, y = y_add_2 }, { x = x_add_4, y = y_add_2 }, { x = x_add_5, y = y_add_2 }, { x = x_add_6, y = y_add_2 }, { x = x_min_6, y = y_add_3 }, { x = x_min_5, y = y_add_3 }, { x = x_min_4, y = y_add_3 }, { x = x_min_3, y = y_add_3 }, { x = x_min_2, y = y_add_3 }, { x = x_min_1, y = y_add_3 }, { x = x_add_0, y = y_add_3 }, { x = x_add_1, y = y_add_3 }, { x = x_add_2, y = y_add_3 }, { x = x_add_3, y = y_add_3 }, { x = x_add_4, y = y_add_3 }, { x = x_add_5, y = y_add_3 }, { x = x_add_6, y = y_add_3 }, { x = x_min_6, y = y_add_4 }, { x = x_min_5, y = y_add_4 }, { x = x_min_4, y = y_add_4 }, { x = x_min_3, y = y_add_4 }, { x = x_min_2, y = y_add_4 }, { x = x_min_1, y = y_add_4 }, { x = x_add_0, y = y_add_4 }, { x = x_add_1, y = y_add_4 }, { x = x_add_2, y = y_add_4 }, { x = x_add_3, y = y_add_4 }, { x = x_add_4, y = y_add_4 }, { x = x_add_5, y = y_add_4 }, { x = x_add_6, y = y_add_4 }, { x = x_min_6, y = y_add_5 }, { x = x_min_5, y = y_add_5 }, { x = x_min_4, y = y_add_5 }, { x = x_min_3, y = y_add_5 }, { x = x_min_2, y = y_add_5 }, { x = x_min_1, y = y_add_5 }, { x = x_add_0, y = y_add_5 }, { x = x_add_1, y = y_add_5 }, { x = x_add_2, y = y_add_5 }, { x = x_add_3, y = y_add_5 }, { x = x_add_4, y = y_add_5 }, { x = x_add_5, y = y_add_5 }, { x = x_add_6, y = y_add_5 }, { x = x_min_6, y = y_add_6 }, { x = x_min_5, y = y_add_6 }, { x = x_min_4, y = y_add_6 }, { x = x_min_3, y = y_add_6 }, { x = x_min_2, y = y_add_6 }, { x = x_min_1, y = y_add_6 }, { x = x_add_0, y = y_add_6 }, { x = x_add_1, y = y_add_6 }, { x = x_add_2, y = y_add_6 }, { x = x_add_3, y = y_add_6 }, { x = x_add_4, y = y_add_6 }, { x = x_add_5, y = y_add_6 }, { x = x_add_6, y = y_add_6 },
        }
    elseif steps == 8 then
        return {
            { x = x_min_8, y = y_min_8 }, { x = x_min_7, y = y_min_8 }, { x = x_min_6, y = y_min_8 }, { x = x_min_5, y = y_min_8 }, { x = x_min_4, y = y_min_8 }, { x = x_min_3, y = y_min_8 }, { x = x_min_2, y = y_min_8 }, { x = x_min_1, y = y_min_8 }, { x = x_add_0, y = y_min_8 }, { x = x_add_1, y = y_min_8 }, { x = x_add_2, y = y_min_8 }, { x = x_add_3, y = y_min_8 }, { x = x_add_4, y = y_min_8 }, { x = x_add_5, y = y_min_8 }, { x = x_add_6, y = y_min_8 }, { x = x_add_7, y = y_min_8 }, { x = x_add_8, y = y_min_8 }, { x = x_min_8, y = y_min_7 }, { x = x_min_7, y = y_min_7 }, { x = x_min_6, y = y_min_7 }, { x = x_min_5, y = y_min_7 }, { x = x_min_4, y = y_min_7 }, { x = x_min_3, y = y_min_7 }, { x = x_min_2, y = y_min_7 }, { x = x_min_1, y = y_min_7 }, { x = x_add_0, y = y_min_7 }, { x = x_add_1, y = y_min_7 }, { x = x_add_2, y = y_min_7 }, { x = x_add_3, y = y_min_7 }, { x = x_add_4, y = y_min_7 }, { x = x_add_5, y = y_min_7 }, { x = x_add_6, y = y_min_7 }, { x = x_add_7, y = y_min_7 }, { x = x_add_8, y = y_min_7 }, { x = x_min_8, y = y_min_6 }, { x = x_min_7, y = y_min_6 }, { x = x_min_6, y = y_min_6 }, { x = x_min_5, y = y_min_6 }, { x = x_min_4, y = y_min_6 }, { x = x_min_3, y = y_min_6 }, { x = x_min_2, y = y_min_6 }, { x = x_min_1, y = y_min_6 }, { x = x_add_0, y = y_min_6 }, { x = x_add_1, y = y_min_6 }, { x = x_add_2, y = y_min_6 }, { x = x_add_3, y = y_min_6 }, { x = x_add_4, y = y_min_6 }, { x = x_add_5, y = y_min_6 }, { x = x_add_6, y = y_min_6 }, { x = x_add_7, y = y_min_6 }, { x = x_add_8, y = y_min_6 }, { x = x_min_8, y = y_min_5 }, { x = x_min_7, y = y_min_5 }, { x = x_min_6, y = y_min_5 }, { x = x_min_5, y = y_min_5 }, { x = x_min_4, y = y_min_5 }, { x = x_min_3, y = y_min_5 }, { x = x_min_2, y = y_min_5 }, { x = x_min_1, y = y_min_5 }, { x = x_add_0, y = y_min_5 }, { x = x_add_1, y = y_min_5 }, { x = x_add_2, y = y_min_5 }, { x = x_add_3, y = y_min_5 }, { x = x_add_4, y = y_min_5 }, { x = x_add_5, y = y_min_5 }, { x = x_add_6, y = y_min_5 }, { x = x_add_7, y = y_min_5 }, { x = x_add_8, y = y_min_5 }, { x = x_min_8, y = y_min_4 }, { x = x_min_7, y = y_min_4 }, { x = x_min_6, y = y_min_4 }, { x = x_min_5, y = y_min_4 }, { x = x_min_4, y = y_min_4 }, { x = x_min_3, y = y_min_4 }, { x = x_min_2, y = y_min_4 }, { x = x_min_1, y = y_min_4 }, { x = x_add_0, y = y_min_4 }, { x = x_add_1, y = y_min_4 }, { x = x_add_2, y = y_min_4 }, { x = x_add_3, y = y_min_4 }, { x = x_add_4, y = y_min_4 }, { x = x_add_5, y = y_min_4 }, { x = x_add_6, y = y_min_4 }, { x = x_add_7, y = y_min_4 }, { x = x_add_8, y = y_min_4 }, { x = x_min_8, y = y_min_3 }, { x = x_min_7, y = y_min_3 }, { x = x_min_6, y = y_min_3 }, { x = x_min_5, y = y_min_3 }, { x = x_min_4, y = y_min_3 }, { x = x_min_3, y = y_min_3 }, { x = x_min_2, y = y_min_3 }, { x = x_min_1, y = y_min_3 }, { x = x_add_0, y = y_min_3 }, { x = x_add_1, y = y_min_3 }, { x = x_add_2, y = y_min_3 }, { x = x_add_3, y = y_min_3 }, { x = x_add_4, y = y_min_3 }, { x = x_add_5, y = y_min_3 }, { x = x_add_6, y = y_min_3 }, { x = x_add_7, y = y_min_3 }, { x = x_add_8, y = y_min_3 }, { x = x_min_8, y = y_min_2 }, { x = x_min_7, y = y_min_2 }, { x = x_min_6, y = y_min_2 }, { x = x_min_5, y = y_min_2 }, { x = x_min_4, y = y_min_2 }, { x = x_min_3, y = y_min_2 }, { x = x_min_2, y = y_min_2 }, { x = x_min_1, y = y_min_2 }, { x = x_add_0, y = y_min_2 }, { x = x_add_1, y = y_min_2 }, { x = x_add_2, y = y_min_2 }, { x = x_add_3, y = y_min_2 }, { x = x_add_4, y = y_min_2 }, { x = x_add_5, y = y_min_2 }, { x = x_add_6, y = y_min_2 }, { x = x_add_7, y = y_min_2 }, { x = x_add_8, y = y_min_2 }, { x = x_min_8, y = y_min_1 }, { x = x_min_7, y = y_min_1 }, { x = x_min_6, y = y_min_1 }, { x = x_min_5, y = y_min_1 }, { x = x_min_4, y = y_min_1 }, { x = x_min_3, y = y_min_1 }, { x = x_min_2, y = y_min_1 }, { x = x_min_1, y = y_min_1 }, { x = x_add_0, y = y_min_1 }, { x = x_add_1, y = y_min_1 }, { x = x_add_2, y = y_min_1 }, { x = x_add_3, y = y_min_1 }, { x = x_add_4, y = y_min_1 }, { x = x_add_5, y = y_min_1 }, { x = x_add_6, y = y_min_1 }, { x = x_add_7, y = y_min_1 }, { x = x_add_8, y = y_min_1 }, { x = x_min_8, y = y_add_0 }, { x = x_min_7, y = y_add_0 }, { x = x_min_6, y = y_add_0 }, { x = x_min_5, y = y_add_0 }, { x = x_min_4, y = y_add_0 }, { x = x_min_3, y = y_add_0 }, { x = x_min_2, y = y_add_0 }, { x = x_min_1, y = y_add_0 }, { x = x_add_0, y = y_add_0 }, { x = x_add_1, y = y_add_0 }, { x = x_add_2, y = y_add_0 }, { x = x_add_3, y = y_add_0 }, { x = x_add_4, y = y_add_0 }, { x = x_add_5, y = y_add_0 }, { x = x_add_6, y = y_add_0 }, { x = x_add_7, y = y_add_0 }, { x = x_add_8, y = y_add_0 }, { x = x_min_8, y = y_add_1 }, { x = x_min_7, y = y_add_1 }, { x = x_min_6, y = y_add_1 }, { x = x_min_5, y = y_add_1 }, { x = x_min_4, y = y_add_1 }, { x = x_min_3, y = y_add_1 }, { x = x_min_2, y = y_add_1 }, { x = x_min_1, y = y_add_1 }, { x = x_add_0, y = y_add_1 }, { x = x_add_1, y = y_add_1 }, { x = x_add_2, y = y_add_1 }, { x = x_add_3, y = y_add_1 }, { x = x_add_4, y = y_add_1 }, { x = x_add_5, y = y_add_1 }, { x = x_add_6, y = y_add_1 }, { x = x_add_7, y = y_add_1 }, { x = x_add_8, y = y_add_1 }, { x = x_min_8, y = y_add_2 }, { x = x_min_7, y = y_add_2 }, { x = x_min_6, y = y_add_2 }, { x = x_min_5, y = y_add_2 }, { x = x_min_4, y = y_add_2 }, { x = x_min_3, y = y_add_2 }, { x = x_min_2, y = y_add_2 }, { x = x_min_1, y = y_add_2 }, { x = x_add_0, y = y_add_2 }, { x = x_add_1, y = y_add_2 }, { x = x_add_2, y = y_add_2 }, { x = x_add_3, y = y_add_2 }, { x = x_add_4, y = y_add_2 }, { x = x_add_5, y = y_add_2 }, { x = x_add_6, y = y_add_2 }, { x = x_add_7, y = y_add_2 }, { x = x_add_8, y = y_add_2 }, { x = x_min_8, y = y_add_3 }, { x = x_min_7, y = y_add_3 }, { x = x_min_6, y = y_add_3 }, { x = x_min_5, y = y_add_3 }, { x = x_min_4, y = y_add_3 }, { x = x_min_3, y = y_add_3 }, { x = x_min_2, y = y_add_3 }, { x = x_min_1, y = y_add_3 }, { x = x_add_0, y = y_add_3 }, { x = x_add_1, y = y_add_3 }, { x = x_add_2, y = y_add_3 }, { x = x_add_3, y = y_add_3 }, { x = x_add_4, y = y_add_3 }, { x = x_add_5, y = y_add_3 }, { x = x_add_6, y = y_add_3 }, { x = x_add_7, y = y_add_3 }, { x = x_add_8, y = y_add_3 }, { x = x_min_8, y = y_add_4 }, { x = x_min_7, y = y_add_4 }, { x = x_min_6, y = y_add_4 }, { x = x_min_5, y = y_add_4 }, { x = x_min_4, y = y_add_4 }, { x = x_min_3, y = y_add_4 }, { x = x_min_2, y = y_add_4 }, { x = x_min_1, y = y_add_4 }, { x = x_add_0, y = y_add_4 }, { x = x_add_1, y = y_add_4 }, { x = x_add_2, y = y_add_4 }, { x = x_add_3, y = y_add_4 }, { x = x_add_4, y = y_add_4 }, { x = x_add_5, y = y_add_4 }, { x = x_add_6, y = y_add_4 }, { x = x_add_7, y = y_add_4 }, { x = x_add_8, y = y_add_4 }, { x = x_min_8, y = y_add_5 }, { x = x_min_7, y = y_add_5 }, { x = x_min_6, y = y_add_5 }, { x = x_min_5, y = y_add_5 }, { x = x_min_4, y = y_add_5 }, { x = x_min_3, y = y_add_5 }, { x = x_min_2, y = y_add_5 }, { x = x_min_1, y = y_add_5 }, { x = x_add_0, y = y_add_5 }, { x = x_add_1, y = y_add_5 }, { x = x_add_2, y = y_add_5 }, { x = x_add_3, y = y_add_5 }, { x = x_add_4, y = y_add_5 }, { x = x_add_5, y = y_add_5 }, { x = x_add_6, y = y_add_5 }, { x = x_add_7, y = y_add_5 }, { x = x_add_8, y = y_add_5 }, { x = x_min_8, y = y_add_6 }, { x = x_min_7, y = y_add_6 }, { x = x_min_6, y = y_add_6 }, { x = x_min_5, y = y_add_6 }, { x = x_min_4, y = y_add_6 }, { x = x_min_3, y = y_add_6 }, { x = x_min_2, y = y_add_6 }, { x = x_min_1, y = y_add_6 }, { x = x_add_0, y = y_add_6 }, { x = x_add_1, y = y_add_6 }, { x = x_add_2, y = y_add_6 }, { x = x_add_3, y = y_add_6 }, { x = x_add_4, y = y_add_6 }, { x = x_add_5, y = y_add_6 }, { x = x_add_6, y = y_add_6 }, { x = x_add_7, y = y_add_6 }, { x = x_add_8, y = y_add_6 }, { x = x_min_8, y = y_add_7 }, { x = x_min_7, y = y_add_7 }, { x = x_min_6, y = y_add_7 }, { x = x_min_5, y = y_add_7 }, { x = x_min_4, y = y_add_7 }, { x = x_min_3, y = y_add_7 }, { x = x_min_2, y = y_add_7 }, { x = x_min_1, y = y_add_7 }, { x = x_add_0, y = y_add_7 }, { x = x_add_1, y = y_add_7 }, { x = x_add_2, y = y_add_7 }, { x = x_add_3, y = y_add_7 }, { x = x_add_4, y = y_add_7 }, { x = x_add_5, y = y_add_7 }, { x = x_add_6, y = y_add_7 }, { x = x_add_7, y = y_add_7 }, { x = x_add_8, y = y_add_7 }, { x = x_min_8, y = y_add_8 }, { x = x_min_7, y = y_add_8 }, { x = x_min_6, y = y_add_8 }, { x = x_min_5, y = y_add_8 }, { x = x_min_4, y = y_add_8 }, { x = x_min_3, y = y_add_8 }, { x = x_min_2, y = y_add_8 }, { x = x_min_1, y = y_add_8 }, { x = x_add_0, y = y_add_8 }, { x = x_add_1, y = y_add_8 }, { x = x_add_2, y = y_add_8 }, { x = x_add_3, y = y_add_8 }, { x = x_add_4, y = y_add_8 }, { x = x_add_5, y = y_add_8 }, { x = x_add_6, y = y_add_8 }, { x = x_add_7, y = y_add_8 }, { x = x_add_8, y = y_add_8 },
        }
    elseif steps == 12 then
        return {
            { x = x_min_12, y = y_min_12 }, { x = x_min_11, y = y_min_12 }, { x = x_min_10, y = y_min_12 }, { x = x_min_9, y = y_min_12 }, { x = x_min_8, y = y_min_12 }, { x = x_min_7, y = y_min_12 }, { x = x_min_6, y = y_min_12 }, { x = x_min_5, y = y_min_12 }, { x = x_min_4, y = y_min_12 }, { x = x_min_3, y = y_min_12 }, { x = x_min_2, y = y_min_12 }, { x = x_min_1, y = y_min_12 }, { x = x_add_0, y = y_min_12 }, { x = x_add_1, y = y_min_12 }, { x = x_add_2, y = y_min_12 }, { x = x_add_3, y = y_min_12 }, { x = x_add_4, y = y_min_12 }, { x = x_add_5, y = y_min_12 }, { x = x_add_6, y = y_min_12 }, { x = x_add_7, y = y_min_12 }, { x = x_add_8, y = y_min_12 }, { x = x_add_9, y = y_min_12 }, { x = x_add_10, y = y_min_12 }, { x = x_add_11, y = y_min_12 }, { x = x_add_12, y = y_min_12 }, { x = x_min_12, y = y_min_11 }, { x = x_min_11, y = y_min_11 }, { x = x_min_10, y = y_min_11 }, { x = x_min_9, y = y_min_11 }, { x = x_min_8, y = y_min_11 }, { x = x_min_7, y = y_min_11 }, { x = x_min_6, y = y_min_11 }, { x = x_min_5, y = y_min_11 }, { x = x_min_4, y = y_min_11 }, { x = x_min_3, y = y_min_11 }, { x = x_min_2, y = y_min_11 }, { x = x_min_1, y = y_min_11 }, { x = x_add_0, y = y_min_11 }, { x = x_add_1, y = y_min_11 }, { x = x_add_2, y = y_min_11 }, { x = x_add_3, y = y_min_11 }, { x = x_add_4, y = y_min_11 }, { x = x_add_5, y = y_min_11 }, { x = x_add_6, y = y_min_11 }, { x = x_add_7, y = y_min_11 }, { x = x_add_8, y = y_min_11 }, { x = x_add_9, y = y_min_11 }, { x = x_add_10, y = y_min_11 }, { x = x_add_11, y = y_min_11 }, { x = x_add_12, y = y_min_11 }, { x = x_min_12, y = y_min_10 }, { x = x_min_11, y = y_min_10 }, { x = x_min_10, y = y_min_10 }, { x = x_min_9, y = y_min_10 }, { x = x_min_8, y = y_min_10 }, { x = x_min_7, y = y_min_10 }, { x = x_min_6, y = y_min_10 }, { x = x_min_5, y = y_min_10 }, { x = x_min_4, y = y_min_10 }, { x = x_min_3, y = y_min_10 }, { x = x_min_2, y = y_min_10 }, { x = x_min_1, y = y_min_10 }, { x = x_add_0, y = y_min_10 }, { x = x_add_1, y = y_min_10 }, { x = x_add_2, y = y_min_10 }, { x = x_add_3, y = y_min_10 }, { x = x_add_4, y = y_min_10 }, { x = x_add_5, y = y_min_10 }, { x = x_add_6, y = y_min_10 }, { x = x_add_7, y = y_min_10 }, { x = x_add_8, y = y_min_10 }, { x = x_add_9, y = y_min_10 }, { x = x_add_10, y = y_min_10 }, { x = x_add_11, y = y_min_10 }, { x = x_add_12, y = y_min_10 }, { x = x_min_12, y = y_min_9 }, { x = x_min_11, y = y_min_9 }, { x = x_min_10, y = y_min_9 }, { x = x_min_9, y = y_min_9 }, { x = x_min_8, y = y_min_9 }, { x = x_min_7, y = y_min_9 }, { x = x_min_6, y = y_min_9 }, { x = x_min_5, y = y_min_9 }, { x = x_min_4, y = y_min_9 }, { x = x_min_3, y = y_min_9 }, { x = x_min_2, y = y_min_9 }, { x = x_min_1, y = y_min_9 }, { x = x_add_0, y = y_min_9 }, { x = x_add_1, y = y_min_9 }, { x = x_add_2, y = y_min_9 }, { x = x_add_3, y = y_min_9 }, { x = x_add_4, y = y_min_9 }, { x = x_add_5, y = y_min_9 }, { x = x_add_6, y = y_min_9 }, { x = x_add_7, y = y_min_9 }, { x = x_add_8, y = y_min_9 }, { x = x_add_9, y = y_min_9 }, { x = x_add_10, y = y_min_9 }, { x = x_add_11, y = y_min_9 }, { x = x_add_12, y = y_min_9 }, { x = x_min_12, y = y_min_8 }, { x = x_min_11, y = y_min_8 }, { x = x_min_10, y = y_min_8 }, { x = x_min_9, y = y_min_8 }, { x = x_min_8, y = y_min_8 }, { x = x_min_7, y = y_min_8 }, { x = x_min_6, y = y_min_8 }, { x = x_min_5, y = y_min_8 }, { x = x_min_4, y = y_min_8 }, { x = x_min_3, y = y_min_8 }, { x = x_min_2, y = y_min_8 }, { x = x_min_1, y = y_min_8 }, { x = x_add_0, y = y_min_8 }, { x = x_add_1, y = y_min_8 }, { x = x_add_2, y = y_min_8 }, { x = x_add_3, y = y_min_8 }, { x = x_add_4, y = y_min_8 }, { x = x_add_5, y = y_min_8 }, { x = x_add_6, y = y_min_8 }, { x = x_add_7, y = y_min_8 }, { x = x_add_8, y = y_min_8 }, { x = x_add_9, y = y_min_8 }, { x = x_add_10, y = y_min_8 }, { x = x_add_11, y = y_min_8 }, { x = x_add_12, y = y_min_8 }, { x = x_min_12, y = y_min_7 }, { x = x_min_11, y = y_min_7 }, { x = x_min_10, y = y_min_7 }, { x = x_min_9, y = y_min_7 }, { x = x_min_8, y = y_min_7 }, { x = x_min_7, y = y_min_7 }, { x = x_min_6, y = y_min_7 }, { x = x_min_5, y = y_min_7 }, { x = x_min_4, y = y_min_7 }, { x = x_min_3, y = y_min_7 }, { x = x_min_2, y = y_min_7 }, { x = x_min_1, y = y_min_7 }, { x = x_add_0, y = y_min_7 }, { x = x_add_1, y = y_min_7 }, { x = x_add_2, y = y_min_7 }, { x = x_add_3, y = y_min_7 }, { x = x_add_4, y = y_min_7 }, { x = x_add_5, y = y_min_7 }, { x = x_add_6, y = y_min_7 }, { x = x_add_7, y = y_min_7 }, { x = x_add_8, y = y_min_7 }, { x = x_add_9, y = y_min_7 }, { x = x_add_10, y = y_min_7 }, { x = x_add_11, y = y_min_7 }, { x = x_add_12, y = y_min_7 }, { x = x_min_12, y = y_min_6 }, { x = x_min_11, y = y_min_6 }, { x = x_min_10, y = y_min_6 }, { x = x_min_9, y = y_min_6 }, { x = x_min_8, y = y_min_6 }, { x = x_min_7, y = y_min_6 }, { x = x_min_6, y = y_min_6 }, { x = x_min_5, y = y_min_6 }, { x = x_min_4, y = y_min_6 }, { x = x_min_3, y = y_min_6 }, { x = x_min_2, y = y_min_6 }, { x = x_min_1, y = y_min_6 }, { x = x_add_0, y = y_min_6 }, { x = x_add_1, y = y_min_6 }, { x = x_add_2, y = y_min_6 }, { x = x_add_3, y = y_min_6 }, { x = x_add_4, y = y_min_6 }, { x = x_add_5, y = y_min_6 }, { x = x_add_6, y = y_min_6 }, { x = x_add_7, y = y_min_6 }, { x = x_add_8, y = y_min_6 }, { x = x_add_9, y = y_min_6 }, { x = x_add_10, y = y_min_6 }, { x = x_add_11, y = y_min_6 }, { x = x_add_12, y = y_min_6 }, { x = x_min_12, y = y_min_5 }, { x = x_min_11, y = y_min_5 }, { x = x_min_10, y = y_min_5 }, { x = x_min_9, y = y_min_5 }, { x = x_min_8, y = y_min_5 }, { x = x_min_7, y = y_min_5 }, { x = x_min_6, y = y_min_5 }, { x = x_min_5, y = y_min_5 }, { x = x_min_4, y = y_min_5 }, { x = x_min_3, y = y_min_5 }, { x = x_min_2, y = y_min_5 }, { x = x_min_1, y = y_min_5 }, { x = x_add_0, y = y_min_5 }, { x = x_add_1, y = y_min_5 }, { x = x_add_2, y = y_min_5 }, { x = x_add_3, y = y_min_5 }, { x = x_add_4, y = y_min_5 }, { x = x_add_5, y = y_min_5 }, { x = x_add_6, y = y_min_5 }, { x = x_add_7, y = y_min_5 }, { x = x_add_8, y = y_min_5 }, { x = x_add_9, y = y_min_5 }, { x = x_add_10, y = y_min_5 }, { x = x_add_11, y = y_min_5 }, { x = x_add_12, y = y_min_5 }, { x = x_min_12, y = y_min_4 }, { x = x_min_11, y = y_min_4 }, { x = x_min_10, y = y_min_4 }, { x = x_min_9, y = y_min_4 }, { x = x_min_8, y = y_min_4 }, { x = x_min_7, y = y_min_4 }, { x = x_min_6, y = y_min_4 }, { x = x_min_5, y = y_min_4 }, { x = x_min_4, y = y_min_4 }, { x = x_min_3, y = y_min_4 }, { x = x_min_2, y = y_min_4 }, { x = x_min_1, y = y_min_4 }, { x = x_add_0, y = y_min_4 }, { x = x_add_1, y = y_min_4 }, { x = x_add_2, y = y_min_4 }, { x = x_add_3, y = y_min_4 }, { x = x_add_4, y = y_min_4 }, { x = x_add_5, y = y_min_4 }, { x = x_add_6, y = y_min_4 }, { x = x_add_7, y = y_min_4 }, { x = x_add_8, y = y_min_4 }, { x = x_add_9, y = y_min_4 }, { x = x_add_10, y = y_min_4 }, { x = x_add_11, y = y_min_4 }, { x = x_add_12, y = y_min_4 }, { x = x_min_12, y = y_min_3 }, { x = x_min_11, y = y_min_3 }, { x = x_min_10, y = y_min_3 }, { x = x_min_9, y = y_min_3 }, { x = x_min_8, y = y_min_3 }, { x = x_min_7, y = y_min_3 }, { x = x_min_6, y = y_min_3 }, { x = x_min_5, y = y_min_3 }, { x = x_min_4, y = y_min_3 }, { x = x_min_3, y = y_min_3 }, { x = x_min_2, y = y_min_3 }, { x = x_min_1, y = y_min_3 }, { x = x_add_0, y = y_min_3 }, { x = x_add_1, y = y_min_3 }, { x = x_add_2, y = y_min_3 }, { x = x_add_3, y = y_min_3 }, { x = x_add_4, y = y_min_3 }, { x = x_add_5, y = y_min_3 }, { x = x_add_6, y = y_min_3 }, { x = x_add_7, y = y_min_3 }, { x = x_add_8, y = y_min_3 }, { x = x_add_9, y = y_min_3 }, { x = x_add_10, y = y_min_3 }, { x = x_add_11, y = y_min_3 }, { x = x_add_12, y = y_min_3 }, { x = x_min_12, y = y_min_2 }, { x = x_min_11, y = y_min_2 }, { x = x_min_10, y = y_min_2 }, { x = x_min_9, y = y_min_2 }, { x = x_min_8, y = y_min_2 }, { x = x_min_7, y = y_min_2 }, { x = x_min_6, y = y_min_2 }, { x = x_min_5, y = y_min_2 }, { x = x_min_4, y = y_min_2 }, { x = x_min_3, y = y_min_2 }, { x = x_min_2, y = y_min_2 }, { x = x_min_1, y = y_min_2 }, { x = x_add_0, y = y_min_2 }, { x = x_add_1, y = y_min_2 }, { x = x_add_2, y = y_min_2 }, { x = x_add_3, y = y_min_2 }, { x = x_add_4, y = y_min_2 }, { x = x_add_5, y = y_min_2 }, { x = x_add_6, y = y_min_2 }, { x = x_add_7, y = y_min_2 }, { x = x_add_8, y = y_min_2 }, { x = x_add_9, y = y_min_2 }, { x = x_add_10, y = y_min_2 }, { x = x_add_11, y = y_min_2 }, { x = x_add_12, y = y_min_2 }, { x = x_min_12, y = y_min_1 }, { x = x_min_11, y = y_min_1 }, { x = x_min_10, y = y_min_1 }, { x = x_min_9, y = y_min_1 }, { x = x_min_8, y = y_min_1 }, { x = x_min_7, y = y_min_1 }, { x = x_min_6, y = y_min_1 }, { x = x_min_5, y = y_min_1 }, { x = x_min_4, y = y_min_1 }, { x = x_min_3, y = y_min_1 }, { x = x_min_2, y = y_min_1 }, { x = x_min_1, y = y_min_1 }, { x = x_add_0, y = y_min_1 }, { x = x_add_1, y = y_min_1 }, { x = x_add_2, y = y_min_1 }, { x = x_add_3, y = y_min_1 }, { x = x_add_4, y = y_min_1 }, { x = x_add_5, y = y_min_1 }, { x = x_add_6, y = y_min_1 }, { x = x_add_7, y = y_min_1 }, { x = x_add_8, y = y_min_1 }, { x = x_add_9, y = y_min_1 }, { x = x_add_10, y = y_min_1 }, { x = x_add_11, y = y_min_1 }, { x = x_add_12, y = y_min_1 }, { x = x_min_12, y = y_add_0 }, { x = x_min_11, y = y_add_0 }, { x = x_min_10, y = y_add_0 }, { x = x_min_9, y = y_add_0 }, { x = x_min_8, y = y_add_0 }, { x = x_min_7, y = y_add_0 }, { x = x_min_6, y = y_add_0 }, { x = x_min_5, y = y_add_0 }, { x = x_min_4, y = y_add_0 }, { x = x_min_3, y = y_add_0 }, { x = x_min_2, y = y_add_0 }, { x = x_min_1, y = y_add_0 }, { x = x_add_0, y = y_add_0 }, { x = x_add_1, y = y_add_0 }, { x = x_add_2, y = y_add_0 }, { x = x_add_3, y = y_add_0 }, { x = x_add_4, y = y_add_0 }, { x = x_add_5, y = y_add_0 }, { x = x_add_6, y = y_add_0 }, { x = x_add_7, y = y_add_0 }, { x = x_add_8, y = y_add_0 }, { x = x_add_9, y = y_add_0 }, { x = x_add_10, y = y_add_0 }, { x = x_add_11, y = y_add_0 }, { x = x_add_12, y = y_add_0 }, { x = x_min_12, y = y_add_1 }, { x = x_min_11, y = y_add_1 }, { x = x_min_10, y = y_add_1 }, { x = x_min_9, y = y_add_1 }, { x = x_min_8, y = y_add_1 }, { x = x_min_7, y = y_add_1 }, { x = x_min_6, y = y_add_1 }, { x = x_min_5, y = y_add_1 }, { x = x_min_4, y = y_add_1 }, { x = x_min_3, y = y_add_1 }, { x = x_min_2, y = y_add_1 }, { x = x_min_1, y = y_add_1 }, { x = x_add_0, y = y_add_1 }, { x = x_add_1, y = y_add_1 }, { x = x_add_2, y = y_add_1 }, { x = x_add_3, y = y_add_1 }, { x = x_add_4, y = y_add_1 }, { x = x_add_5, y = y_add_1 }, { x = x_add_6, y = y_add_1 }, { x = x_add_7, y = y_add_1 }, { x = x_add_8, y = y_add_1 }, { x = x_add_9, y = y_add_1 }, { x = x_add_10, y = y_add_1 }, { x = x_add_11, y = y_add_1 }, { x = x_add_12, y = y_add_1 }, { x = x_min_12, y = y_add_2 }, { x = x_min_11, y = y_add_2 }, { x = x_min_10, y = y_add_2 }, { x = x_min_9, y = y_add_2 }, { x = x_min_8, y = y_add_2 }, { x = x_min_7, y = y_add_2 }, { x = x_min_6, y = y_add_2 }, { x = x_min_5, y = y_add_2 }, { x = x_min_4, y = y_add_2 }, { x = x_min_3, y = y_add_2 }, { x = x_min_2, y = y_add_2 }, { x = x_min_1, y = y_add_2 }, { x = x_add_0, y = y_add_2 }, { x = x_add_1, y = y_add_2 }, { x = x_add_2, y = y_add_2 }, { x = x_add_3, y = y_add_2 }, { x = x_add_4, y = y_add_2 }, { x = x_add_5, y = y_add_2 }, { x = x_add_6, y = y_add_2 }, { x = x_add_7, y = y_add_2 }, { x = x_add_8, y = y_add_2 }, { x = x_add_9, y = y_add_2 }, { x = x_add_10, y = y_add_2 }, { x = x_add_11, y = y_add_2 }, { x = x_add_12, y = y_add_2 }, { x = x_min_12, y = y_add_3 }, { x = x_min_11, y = y_add_3 }, { x = x_min_10, y = y_add_3 }, { x = x_min_9, y = y_add_3 }, { x = x_min_8, y = y_add_3 }, { x = x_min_7, y = y_add_3 }, { x = x_min_6, y = y_add_3 }, { x = x_min_5, y = y_add_3 }, { x = x_min_4, y = y_add_3 }, { x = x_min_3, y = y_add_3 }, { x = x_min_2, y = y_add_3 }, { x = x_min_1, y = y_add_3 }, { x = x_add_0, y = y_add_3 }, { x = x_add_1, y = y_add_3 }, { x = x_add_2, y = y_add_3 }, { x = x_add_3, y = y_add_3 }, { x = x_add_4, y = y_add_3 }, { x = x_add_5, y = y_add_3 }, { x = x_add_6, y = y_add_3 }, { x = x_add_7, y = y_add_3 }, { x = x_add_8, y = y_add_3 }, { x = x_add_9, y = y_add_3 }, { x = x_add_10, y = y_add_3 }, { x = x_add_11, y = y_add_3 }, { x = x_add_12, y = y_add_3 }, { x = x_min_12, y = y_add_4 }, { x = x_min_11, y = y_add_4 }, { x = x_min_10, y = y_add_4 }, { x = x_min_9, y = y_add_4 }, { x = x_min_8, y = y_add_4 }, { x = x_min_7, y = y_add_4 }, { x = x_min_6, y = y_add_4 }, { x = x_min_5, y = y_add_4 }, { x = x_min_4, y = y_add_4 }, { x = x_min_3, y = y_add_4 }, { x = x_min_2, y = y_add_4 }, { x = x_min_1, y = y_add_4 }, { x = x_add_0, y = y_add_4 }, { x = x_add_1, y = y_add_4 }, { x = x_add_2, y = y_add_4 }, { x = x_add_3, y = y_add_4 }, { x = x_add_4, y = y_add_4 }, { x = x_add_5, y = y_add_4 }, { x = x_add_6, y = y_add_4 }, { x = x_add_7, y = y_add_4 }, { x = x_add_8, y = y_add_4 }, { x = x_add_9, y = y_add_4 }, { x = x_add_10, y = y_add_4 }, { x = x_add_11, y = y_add_4 }, { x = x_add_12, y = y_add_4 }, { x = x_min_12, y = y_add_5 }, { x = x_min_11, y = y_add_5 }, { x = x_min_10, y = y_add_5 }, { x = x_min_9, y = y_add_5 }, { x = x_min_8, y = y_add_5 }, { x = x_min_7, y = y_add_5 }, { x = x_min_6, y = y_add_5 }, { x = x_min_5, y = y_add_5 }, { x = x_min_4, y = y_add_5 }, { x = x_min_3, y = y_add_5 }, { x = x_min_2, y = y_add_5 }, { x = x_min_1, y = y_add_5 }, { x = x_add_0, y = y_add_5 }, { x = x_add_1, y = y_add_5 }, { x = x_add_2, y = y_add_5 }, { x = x_add_3, y = y_add_5 }, { x = x_add_4, y = y_add_5 }, { x = x_add_5, y = y_add_5 }, { x = x_add_6, y = y_add_5 }, { x = x_add_7, y = y_add_5 }, { x = x_add_8, y = y_add_5 }, { x = x_add_9, y = y_add_5 }, { x = x_add_10, y = y_add_5 }, { x = x_add_11, y = y_add_5 }, { x = x_add_12, y = y_add_5 }, { x = x_min_12, y = y_add_6 }, { x = x_min_11, y = y_add_6 }, { x = x_min_10, y = y_add_6 }, { x = x_min_9, y = y_add_6 }, { x = x_min_8, y = y_add_6 }, { x = x_min_7, y = y_add_6 }, { x = x_min_6, y = y_add_6 }, { x = x_min_5, y = y_add_6 }, { x = x_min_4, y = y_add_6 }, { x = x_min_3, y = y_add_6 }, { x = x_min_2, y = y_add_6 }, { x = x_min_1, y = y_add_6 }, { x = x_add_0, y = y_add_6 }, { x = x_add_1, y = y_add_6 }, { x = x_add_2, y = y_add_6 }, { x = x_add_3, y = y_add_6 }, { x = x_add_4, y = y_add_6 }, { x = x_add_5, y = y_add_6 }, { x = x_add_6, y = y_add_6 }, { x = x_add_7, y = y_add_6 }, { x = x_add_8, y = y_add_6 }, { x = x_add_9, y = y_add_6 }, { x = x_add_10, y = y_add_6 }, { x = x_add_11, y = y_add_6 }, { x = x_add_12, y = y_add_6 }, { x = x_min_12, y = y_add_7 }, { x = x_min_11, y = y_add_7 }, { x = x_min_10, y = y_add_7 }, { x = x_min_9, y = y_add_7 }, { x = x_min_8, y = y_add_7 }, { x = x_min_7, y = y_add_7 }, { x = x_min_6, y = y_add_7 }, { x = x_min_5, y = y_add_7 }, { x = x_min_4, y = y_add_7 }, { x = x_min_3, y = y_add_7 }, { x = x_min_2, y = y_add_7 }, { x = x_min_1, y = y_add_7 }, { x = x_add_0, y = y_add_7 }, { x = x_add_1, y = y_add_7 }, { x = x_add_2, y = y_add_7 }, { x = x_add_3, y = y_add_7 }, { x = x_add_4, y = y_add_7 }, { x = x_add_5, y = y_add_7 }, { x = x_add_6, y = y_add_7 }, { x = x_add_7, y = y_add_7 }, { x = x_add_8, y = y_add_7 }, { x = x_add_9, y = y_add_7 }, { x = x_add_10, y = y_add_7 }, { x = x_add_11, y = y_add_7 }, { x = x_add_12, y = y_add_7 }, { x = x_min_12, y = y_add_8 }, { x = x_min_11, y = y_add_8 }, { x = x_min_10, y = y_add_8 }, { x = x_min_9, y = y_add_8 }, { x = x_min_8, y = y_add_8 }, { x = x_min_7, y = y_add_8 }, { x = x_min_6, y = y_add_8 }, { x = x_min_5, y = y_add_8 }, { x = x_min_4, y = y_add_8 }, { x = x_min_3, y = y_add_8 }, { x = x_min_2, y = y_add_8 }, { x = x_min_1, y = y_add_8 }, { x = x_add_0, y = y_add_8 }, { x = x_add_1, y = y_add_8 }, { x = x_add_2, y = y_add_8 }, { x = x_add_3, y = y_add_8 }, { x = x_add_4, y = y_add_8 }, { x = x_add_5, y = y_add_8 }, { x = x_add_6, y = y_add_8 }, { x = x_add_7, y = y_add_8 }, { x = x_add_8, y = y_add_8 }, { x = x_add_9, y = y_add_8 }, { x = x_add_10, y = y_add_8 }, { x = x_add_11, y = y_add_8 }, { x = x_add_12, y = y_add_8 }, { x = x_min_12, y = y_add_9 }, { x = x_min_11, y = y_add_9 }, { x = x_min_10, y = y_add_9 }, { x = x_min_9, y = y_add_9 }, { x = x_min_8, y = y_add_9 }, { x = x_min_7, y = y_add_9 }, { x = x_min_6, y = y_add_9 }, { x = x_min_5, y = y_add_9 }, { x = x_min_4, y = y_add_9 }, { x = x_min_3, y = y_add_9 }, { x = x_min_2, y = y_add_9 }, { x = x_min_1, y = y_add_9 }, { x = x_add_0, y = y_add_9 }, { x = x_add_1, y = y_add_9 }, { x = x_add_2, y = y_add_9 }, { x = x_add_3, y = y_add_9 }, { x = x_add_4, y = y_add_9 }, { x = x_add_5, y = y_add_9 }, { x = x_add_6, y = y_add_9 }, { x = x_add_7, y = y_add_9 }, { x = x_add_8, y = y_add_9 }, { x = x_add_9, y = y_add_9 }, { x = x_add_10, y = y_add_9 }, { x = x_add_11, y = y_add_9 }, { x = x_add_12, y = y_add_9 }, { x = x_min_12, y = y_add_10 }, { x = x_min_11, y = y_add_10 }, { x = x_min_10, y = y_add_10 }, { x = x_min_9, y = y_add_10 }, { x = x_min_8, y = y_add_10 }, { x = x_min_7, y = y_add_10 }, { x = x_min_6, y = y_add_10 }, { x = x_min_5, y = y_add_10 }, { x = x_min_4, y = y_add_10 }, { x = x_min_3, y = y_add_10 }, { x = x_min_2, y = y_add_10 }, { x = x_min_1, y = y_add_10 }, { x = x_add_0, y = y_add_10 }, { x = x_add_1, y = y_add_10 }, { x = x_add_2, y = y_add_10 }, { x = x_add_3, y = y_add_10 }, { x = x_add_4, y = y_add_10 }, { x = x_add_5, y = y_add_10 }, { x = x_add_6, y = y_add_10 }, { x = x_add_7, y = y_add_10 }, { x = x_add_8, y = y_add_10 }, { x = x_add_9, y = y_add_10 }, { x = x_add_10, y = y_add_10 }, { x = x_add_11, y = y_add_10 }, { x = x_add_12, y = y_add_10 }, { x = x_min_12, y = y_add_11 }, { x = x_min_11, y = y_add_11 }, { x = x_min_10, y = y_add_11 }, { x = x_min_9, y = y_add_11 }, { x = x_min_8, y = y_add_11 }, { x = x_min_7, y = y_add_11 }, { x = x_min_6, y = y_add_11 }, { x = x_min_5, y = y_add_11 }, { x = x_min_4, y = y_add_11 }, { x = x_min_3, y = y_add_11 }, { x = x_min_2, y = y_add_11 }, { x = x_min_1, y = y_add_11 }, { x = x_add_0, y = y_add_11 }, { x = x_add_1, y = y_add_11 }, { x = x_add_2, y = y_add_11 }, { x = x_add_3, y = y_add_11 }, { x = x_add_4, y = y_add_11 }, { x = x_add_5, y = y_add_11 }, { x = x_add_6, y = y_add_11 }, { x = x_add_7, y = y_add_11 }, { x = x_add_8, y = y_add_11 }, { x = x_add_9, y = y_add_11 }, { x = x_add_10, y = y_add_11 }, { x = x_add_11, y = y_add_11 }, { x = x_add_12, y = y_add_11 }, { x = x_min_12, y = y_add_12 }, { x = x_min_11, y = y_add_12 }, { x = x_min_10, y = y_add_12 }, { x = x_min_9, y = y_add_12 }, { x = x_min_8, y = y_add_12 }, { x = x_min_7, y = y_add_12 }, { x = x_min_6, y = y_add_12 }, { x = x_min_5, y = y_add_12 }, { x = x_min_4, y = y_add_12 }, { x = x_min_3, y = y_add_12 }, { x = x_min_2, y = y_add_12 }, { x = x_min_1, y = y_add_12 }, { x = x_add_0, y = y_add_12 }, { x = x_add_1, y = y_add_12 }, { x = x_add_2, y = y_add_12 }, { x = x_add_3, y = y_add_12 }, { x = x_add_4, y = y_add_12 }, { x = x_add_5, y = y_add_12 }, { x = x_add_6, y = y_add_12 }, { x = x_add_7, y = y_add_12 }, { x = x_add_8, y = y_add_12 }, { x = x_add_9, y = y_add_12 }, { x = x_add_10, y = y_add_12 }, { x = x_add_11, y = y_add_12 }, { x = x_add_12, y = y_add_12 },
        }
    elseif steps == 16 then
        return {
            { x = x_min_16, y = y_min_16 }, { x = x_min_15, y = y_min_16 }, { x = x_min_14, y = y_min_16 }, { x = x_min_13, y = y_min_16 }, { x = x_min_12, y = y_min_16 }, { x = x_min_11, y = y_min_16 }, { x = x_min_10, y = y_min_16 }, { x = x_min_9, y = y_min_16 }, { x = x_min_8, y = y_min_16 }, { x = x_min_7, y = y_min_16 }, { x = x_min_6, y = y_min_16 }, { x = x_min_5, y = y_min_16 }, { x = x_min_4, y = y_min_16 }, { x = x_min_3, y = y_min_16 }, { x = x_min_2, y = y_min_16 }, { x = x_min_1, y = y_min_16 }, { x = x_add_0, y = y_min_16 }, { x = x_add_1, y = y_min_16 }, { x = x_add_2, y = y_min_16 }, { x = x_add_3, y = y_min_16 }, { x = x_add_4, y = y_min_16 }, { x = x_add_5, y = y_min_16 }, { x = x_add_6, y = y_min_16 }, { x = x_add_7, y = y_min_16 }, { x = x_add_8, y = y_min_16 }, { x = x_add_9, y = y_min_16 }, { x = x_add_10, y = y_min_16 }, { x = x_add_11, y = y_min_16 }, { x = x_add_12, y = y_min_16 }, { x = x_add_13, y = y_min_16 }, { x = x_add_14, y = y_min_16 }, { x = x_add_15, y = y_min_16 }, { x = x_add_16, y = y_min_16 }, { x = x_min_16, y = y_min_15 }, { x = x_min_15, y = y_min_15 }, { x = x_min_14, y = y_min_15 }, { x = x_min_13, y = y_min_15 }, { x = x_min_12, y = y_min_15 }, { x = x_min_11, y = y_min_15 }, { x = x_min_10, y = y_min_15 }, { x = x_min_9, y = y_min_15 }, { x = x_min_8, y = y_min_15 }, { x = x_min_7, y = y_min_15 }, { x = x_min_6, y = y_min_15 }, { x = x_min_5, y = y_min_15 }, { x = x_min_4, y = y_min_15 }, { x = x_min_3, y = y_min_15 }, { x = x_min_2, y = y_min_15 }, { x = x_min_1, y = y_min_15 }, { x = x_add_0, y = y_min_15 }, { x = x_add_1, y = y_min_15 }, { x = x_add_2, y = y_min_15 }, { x = x_add_3, y = y_min_15 }, { x = x_add_4, y = y_min_15 }, { x = x_add_5, y = y_min_15 }, { x = x_add_6, y = y_min_15 }, { x = x_add_7, y = y_min_15 }, { x = x_add_8, y = y_min_15 }, { x = x_add_9, y = y_min_15 }, { x = x_add_10, y = y_min_15 }, { x = x_add_11, y = y_min_15 }, { x = x_add_12, y = y_min_15 }, { x = x_add_13, y = y_min_15 }, { x = x_add_14, y = y_min_15 }, { x = x_add_15, y = y_min_15 }, { x = x_add_16, y = y_min_15 }, { x = x_min_16, y = y_min_14 }, { x = x_min_15, y = y_min_14 }, { x = x_min_14, y = y_min_14 }, { x = x_min_13, y = y_min_14 }, { x = x_min_12, y = y_min_14 }, { x = x_min_11, y = y_min_14 }, { x = x_min_10, y = y_min_14 }, { x = x_min_9, y = y_min_14 }, { x = x_min_8, y = y_min_14 }, { x = x_min_7, y = y_min_14 }, { x = x_min_6, y = y_min_14 }, { x = x_min_5, y = y_min_14 }, { x = x_min_4, y = y_min_14 }, { x = x_min_3, y = y_min_14 }, { x = x_min_2, y = y_min_14 }, { x = x_min_1, y = y_min_14 }, { x = x_add_0, y = y_min_14 }, { x = x_add_1, y = y_min_14 }, { x = x_add_2, y = y_min_14 }, { x = x_add_3, y = y_min_14 }, { x = x_add_4, y = y_min_14 }, { x = x_add_5, y = y_min_14 }, { x = x_add_6, y = y_min_14 }, { x = x_add_7, y = y_min_14 }, { x = x_add_8, y = y_min_14 }, { x = x_add_9, y = y_min_14 }, { x = x_add_10, y = y_min_14 }, { x = x_add_11, y = y_min_14 }, { x = x_add_12, y = y_min_14 }, { x = x_add_13, y = y_min_14 }, { x = x_add_14, y = y_min_14 }, { x = x_add_15, y = y_min_14 }, { x = x_add_16, y = y_min_14 }, { x = x_min_16, y = y_min_13 }, { x = x_min_15, y = y_min_13 }, { x = x_min_14, y = y_min_13 }, { x = x_min_13, y = y_min_13 }, { x = x_min_12, y = y_min_13 }, { x = x_min_11, y = y_min_13 }, { x = x_min_10, y = y_min_13 }, { x = x_min_9, y = y_min_13 }, { x = x_min_8, y = y_min_13 }, { x = x_min_7, y = y_min_13 }, { x = x_min_6, y = y_min_13 }, { x = x_min_5, y = y_min_13 }, { x = x_min_4, y = y_min_13 }, { x = x_min_3, y = y_min_13 }, { x = x_min_2, y = y_min_13 }, { x = x_min_1, y = y_min_13 }, { x = x_add_0, y = y_min_13 }, { x = x_add_1, y = y_min_13 }, { x = x_add_2, y = y_min_13 }, { x = x_add_3, y = y_min_13 }, { x = x_add_4, y = y_min_13 }, { x = x_add_5, y = y_min_13 }, { x = x_add_6, y = y_min_13 }, { x = x_add_7, y = y_min_13 }, { x = x_add_8, y = y_min_13 }, { x = x_add_9, y = y_min_13 }, { x = x_add_10, y = y_min_13 }, { x = x_add_11, y = y_min_13 }, { x = x_add_12, y = y_min_13 }, { x = x_add_13, y = y_min_13 }, { x = x_add_14, y = y_min_13 }, { x = x_add_15, y = y_min_13 }, { x = x_add_16, y = y_min_13 }, { x = x_min_16, y = y_min_12 }, { x = x_min_15, y = y_min_12 }, { x = x_min_14, y = y_min_12 }, { x = x_min_13, y = y_min_12 }, { x = x_min_12, y = y_min_12 }, { x = x_min_11, y = y_min_12 }, { x = x_min_10, y = y_min_12 }, { x = x_min_9, y = y_min_12 }, { x = x_min_8, y = y_min_12 }, { x = x_min_7, y = y_min_12 }, { x = x_min_6, y = y_min_12 }, { x = x_min_5, y = y_min_12 }, { x = x_min_4, y = y_min_12 }, { x = x_min_3, y = y_min_12 }, { x = x_min_2, y = y_min_12 }, { x = x_min_1, y = y_min_12 }, { x = x_add_0, y = y_min_12 }, { x = x_add_1, y = y_min_12 }, { x = x_add_2, y = y_min_12 }, { x = x_add_3, y = y_min_12 }, { x = x_add_4, y = y_min_12 }, { x = x_add_5, y = y_min_12 }, { x = x_add_6, y = y_min_12 }, { x = x_add_7, y = y_min_12 }, { x = x_add_8, y = y_min_12 }, { x = x_add_9, y = y_min_12 }, { x = x_add_10, y = y_min_12 }, { x = x_add_11, y = y_min_12 }, { x = x_add_12, y = y_min_12 }, { x = x_add_13, y = y_min_12 }, { x = x_add_14, y = y_min_12 }, { x = x_add_15, y = y_min_12 }, { x = x_add_16, y = y_min_12 }, { x = x_min_16, y = y_min_11 }, { x = x_min_15, y = y_min_11 }, { x = x_min_14, y = y_min_11 }, { x = x_min_13, y = y_min_11 }, { x = x_min_12, y = y_min_11 }, { x = x_min_11, y = y_min_11 }, { x = x_min_10, y = y_min_11 }, { x = x_min_9, y = y_min_11 }, { x = x_min_8, y = y_min_11 }, { x = x_min_7, y = y_min_11 }, { x = x_min_6, y = y_min_11 }, { x = x_min_5, y = y_min_11 }, { x = x_min_4, y = y_min_11 }, { x = x_min_3, y = y_min_11 }, { x = x_min_2, y = y_min_11 }, { x = x_min_1, y = y_min_11 }, { x = x_add_0, y = y_min_11 }, { x = x_add_1, y = y_min_11 }, { x = x_add_2, y = y_min_11 }, { x = x_add_3, y = y_min_11 }, { x = x_add_4, y = y_min_11 }, { x = x_add_5, y = y_min_11 }, { x = x_add_6, y = y_min_11 }, { x = x_add_7, y = y_min_11 }, { x = x_add_8, y = y_min_11 }, { x = x_add_9, y = y_min_11 }, { x = x_add_10, y = y_min_11 }, { x = x_add_11, y = y_min_11 }, { x = x_add_12, y = y_min_11 }, { x = x_add_13, y = y_min_11 }, { x = x_add_14, y = y_min_11 }, { x = x_add_15, y = y_min_11 }, { x = x_add_16, y = y_min_11 }, { x = x_min_16, y = y_min_10 }, { x = x_min_15, y = y_min_10 }, { x = x_min_14, y = y_min_10 }, { x = x_min_13, y = y_min_10 }, { x = x_min_12, y = y_min_10 }, { x = x_min_11, y = y_min_10 }, { x = x_min_10, y = y_min_10 }, { x = x_min_9, y = y_min_10 }, { x = x_min_8, y = y_min_10 }, { x = x_min_7, y = y_min_10 }, { x = x_min_6, y = y_min_10 }, { x = x_min_5, y = y_min_10 }, { x = x_min_4, y = y_min_10 }, { x = x_min_3, y = y_min_10 }, { x = x_min_2, y = y_min_10 }, { x = x_min_1, y = y_min_10 }, { x = x_add_0, y = y_min_10 }, { x = x_add_1, y = y_min_10 }, { x = x_add_2, y = y_min_10 }, { x = x_add_3, y = y_min_10 }, { x = x_add_4, y = y_min_10 }, { x = x_add_5, y = y_min_10 }, { x = x_add_6, y = y_min_10 }, { x = x_add_7, y = y_min_10 }, { x = x_add_8, y = y_min_10 }, { x = x_add_9, y = y_min_10 }, { x = x_add_10, y = y_min_10 }, { x = x_add_11, y = y_min_10 }, { x = x_add_12, y = y_min_10 }, { x = x_add_13, y = y_min_10 }, { x = x_add_14, y = y_min_10 }, { x = x_add_15, y = y_min_10 }, { x = x_add_16, y = y_min_10 }, { x = x_min_16, y = y_min_9 }, { x = x_min_15, y = y_min_9 }, { x = x_min_14, y = y_min_9 }, { x = x_min_13, y = y_min_9 }, { x = x_min_12, y = y_min_9 }, { x = x_min_11, y = y_min_9 }, { x = x_min_10, y = y_min_9 }, { x = x_min_9, y = y_min_9 }, { x = x_min_8, y = y_min_9 }, { x = x_min_7, y = y_min_9 }, { x = x_min_6, y = y_min_9 }, { x = x_min_5, y = y_min_9 }, { x = x_min_4, y = y_min_9 }, { x = x_min_3, y = y_min_9 }, { x = x_min_2, y = y_min_9 }, { x = x_min_1, y = y_min_9 }, { x = x_add_0, y = y_min_9 }, { x = x_add_1, y = y_min_9 }, { x = x_add_2, y = y_min_9 }, { x = x_add_3, y = y_min_9 }, { x = x_add_4, y = y_min_9 }, { x = x_add_5, y = y_min_9 }, { x = x_add_6, y = y_min_9 }, { x = x_add_7, y = y_min_9 }, { x = x_add_8, y = y_min_9 }, { x = x_add_9, y = y_min_9 }, { x = x_add_10, y = y_min_9 }, { x = x_add_11, y = y_min_9 }, { x = x_add_12, y = y_min_9 }, { x = x_add_13, y = y_min_9 }, { x = x_add_14, y = y_min_9 }, { x = x_add_15, y = y_min_9 }, { x = x_add_16, y = y_min_9 }, { x = x_min_16, y = y_min_8 }, { x = x_min_15, y = y_min_8 }, { x = x_min_14, y = y_min_8 }, { x = x_min_13, y = y_min_8 }, { x = x_min_12, y = y_min_8 }, { x = x_min_11, y = y_min_8 }, { x = x_min_10, y = y_min_8 }, { x = x_min_9, y = y_min_8 }, { x = x_min_8, y = y_min_8 }, { x = x_min_7, y = y_min_8 }, { x = x_min_6, y = y_min_8 }, { x = x_min_5, y = y_min_8 }, { x = x_min_4, y = y_min_8 }, { x = x_min_3, y = y_min_8 }, { x = x_min_2, y = y_min_8 }, { x = x_min_1, y = y_min_8 }, { x = x_add_0, y = y_min_8 }, { x = x_add_1, y = y_min_8 }, { x = x_add_2, y = y_min_8 }, { x = x_add_3, y = y_min_8 }, { x = x_add_4, y = y_min_8 }, { x = x_add_5, y = y_min_8 }, { x = x_add_6, y = y_min_8 }, { x = x_add_7, y = y_min_8 }, { x = x_add_8, y = y_min_8 }, { x = x_add_9, y = y_min_8 }, { x = x_add_10, y = y_min_8 }, { x = x_add_11, y = y_min_8 }, { x = x_add_12, y = y_min_8 }, { x = x_add_13, y = y_min_8 }, { x = x_add_14, y = y_min_8 }, { x = x_add_15, y = y_min_8 }, { x = x_add_16, y = y_min_8 }, { x = x_min_16, y = y_min_7 }, { x = x_min_15, y = y_min_7 }, { x = x_min_14, y = y_min_7 }, { x = x_min_13, y = y_min_7 }, { x = x_min_12, y = y_min_7 }, { x = x_min_11, y = y_min_7 }, { x = x_min_10, y = y_min_7 }, { x = x_min_9, y = y_min_7 }, { x = x_min_8, y = y_min_7 }, { x = x_min_7, y = y_min_7 }, { x = x_min_6, y = y_min_7 }, { x = x_min_5, y = y_min_7 }, { x = x_min_4, y = y_min_7 }, { x = x_min_3, y = y_min_7 }, { x = x_min_2, y = y_min_7 }, { x = x_min_1, y = y_min_7 }, { x = x_add_0, y = y_min_7 }, { x = x_add_1, y = y_min_7 }, { x = x_add_2, y = y_min_7 }, { x = x_add_3, y = y_min_7 }, { x = x_add_4, y = y_min_7 }, { x = x_add_5, y = y_min_7 }, { x = x_add_6, y = y_min_7 }, { x = x_add_7, y = y_min_7 }, { x = x_add_8, y = y_min_7 }, { x = x_add_9, y = y_min_7 }, { x = x_add_10, y = y_min_7 }, { x = x_add_11, y = y_min_7 }, { x = x_add_12, y = y_min_7 }, { x = x_add_13, y = y_min_7 }, { x = x_add_14, y = y_min_7 }, { x = x_add_15, y = y_min_7 }, { x = x_add_16, y = y_min_7 }, { x = x_min_16, y = y_min_6 }, { x = x_min_15, y = y_min_6 }, { x = x_min_14, y = y_min_6 }, { x = x_min_13, y = y_min_6 }, { x = x_min_12, y = y_min_6 }, { x = x_min_11, y = y_min_6 }, { x = x_min_10, y = y_min_6 }, { x = x_min_9, y = y_min_6 }, { x = x_min_8, y = y_min_6 }, { x = x_min_7, y = y_min_6 }, { x = x_min_6, y = y_min_6 }, { x = x_min_5, y = y_min_6 }, { x = x_min_4, y = y_min_6 }, { x = x_min_3, y = y_min_6 }, { x = x_min_2, y = y_min_6 }, { x = x_min_1, y = y_min_6 }, { x = x_add_0, y = y_min_6 }, { x = x_add_1, y = y_min_6 }, { x = x_add_2, y = y_min_6 }, { x = x_add_3, y = y_min_6 }, { x = x_add_4, y = y_min_6 }, { x = x_add_5, y = y_min_6 }, { x = x_add_6, y = y_min_6 }, { x = x_add_7, y = y_min_6 }, { x = x_add_8, y = y_min_6 }, { x = x_add_9, y = y_min_6 }, { x = x_add_10, y = y_min_6 }, { x = x_add_11, y = y_min_6 }, { x = x_add_12, y = y_min_6 }, { x = x_add_13, y = y_min_6 }, { x = x_add_14, y = y_min_6 }, { x = x_add_15, y = y_min_6 }, { x = x_add_16, y = y_min_6 }, { x = x_min_16, y = y_min_5 }, { x = x_min_15, y = y_min_5 }, { x = x_min_14, y = y_min_5 }, { x = x_min_13, y = y_min_5 }, { x = x_min_12, y = y_min_5 }, { x = x_min_11, y = y_min_5 }, { x = x_min_10, y = y_min_5 }, { x = x_min_9, y = y_min_5 }, { x = x_min_8, y = y_min_5 }, { x = x_min_7, y = y_min_5 }, { x = x_min_6, y = y_min_5 }, { x = x_min_5, y = y_min_5 }, { x = x_min_4, y = y_min_5 }, { x = x_min_3, y = y_min_5 }, { x = x_min_2, y = y_min_5 }, { x = x_min_1, y = y_min_5 }, { x = x_add_0, y = y_min_5 }, { x = x_add_1, y = y_min_5 }, { x = x_add_2, y = y_min_5 }, { x = x_add_3, y = y_min_5 }, { x = x_add_4, y = y_min_5 }, { x = x_add_5, y = y_min_5 }, { x = x_add_6, y = y_min_5 }, { x = x_add_7, y = y_min_5 }, { x = x_add_8, y = y_min_5 }, { x = x_add_9, y = y_min_5 }, { x = x_add_10, y = y_min_5 }, { x = x_add_11, y = y_min_5 }, { x = x_add_12, y = y_min_5 }, { x = x_add_13, y = y_min_5 }, { x = x_add_14, y = y_min_5 }, { x = x_add_15, y = y_min_5 }, { x = x_add_16, y = y_min_5 }, { x = x_min_16, y = y_min_4 }, { x = x_min_15, y = y_min_4 }, { x = x_min_14, y = y_min_4 }, { x = x_min_13, y = y_min_4 }, { x = x_min_12, y = y_min_4 }, { x = x_min_11, y = y_min_4 }, { x = x_min_10, y = y_min_4 }, { x = x_min_9, y = y_min_4 }, { x = x_min_8, y = y_min_4 }, { x = x_min_7, y = y_min_4 }, { x = x_min_6, y = y_min_4 }, { x = x_min_5, y = y_min_4 }, { x = x_min_4, y = y_min_4 }, { x = x_min_3, y = y_min_4 }, { x = x_min_2, y = y_min_4 }, { x = x_min_1, y = y_min_4 }, { x = x_add_0, y = y_min_4 }, { x = x_add_1, y = y_min_4 }, { x = x_add_2, y = y_min_4 }, { x = x_add_3, y = y_min_4 }, { x = x_add_4, y = y_min_4 }, { x = x_add_5, y = y_min_4 }, { x = x_add_6, y = y_min_4 }, { x = x_add_7, y = y_min_4 }, { x = x_add_8, y = y_min_4 }, { x = x_add_9, y = y_min_4 }, { x = x_add_10, y = y_min_4 }, { x = x_add_11, y = y_min_4 }, { x = x_add_12, y = y_min_4 }, { x = x_add_13, y = y_min_4 }, { x = x_add_14, y = y_min_4 }, { x = x_add_15, y = y_min_4 }, { x = x_add_16, y = y_min_4 }, { x = x_min_16, y = y_min_3 }, { x = x_min_15, y = y_min_3 }, { x = x_min_14, y = y_min_3 }, { x = x_min_13, y = y_min_3 }, { x = x_min_12, y = y_min_3 }, { x = x_min_11, y = y_min_3 }, { x = x_min_10, y = y_min_3 }, { x = x_min_9, y = y_min_3 }, { x = x_min_8, y = y_min_3 }, { x = x_min_7, y = y_min_3 }, { x = x_min_6, y = y_min_3 }, { x = x_min_5, y = y_min_3 }, { x = x_min_4, y = y_min_3 }, { x = x_min_3, y = y_min_3 }, { x = x_min_2, y = y_min_3 }, { x = x_min_1, y = y_min_3 }, { x = x_add_0, y = y_min_3 }, { x = x_add_1, y = y_min_3 }, { x = x_add_2, y = y_min_3 }, { x = x_add_3, y = y_min_3 }, { x = x_add_4, y = y_min_3 }, { x = x_add_5, y = y_min_3 }, { x = x_add_6, y = y_min_3 }, { x = x_add_7, y = y_min_3 }, { x = x_add_8, y = y_min_3 }, { x = x_add_9, y = y_min_3 }, { x = x_add_10, y = y_min_3 }, { x = x_add_11, y = y_min_3 }, { x = x_add_12, y = y_min_3 }, { x = x_add_13, y = y_min_3 }, { x = x_add_14, y = y_min_3 }, { x = x_add_15, y = y_min_3 }, { x = x_add_16, y = y_min_3 }, { x = x_min_16, y = y_min_2 }, { x = x_min_15, y = y_min_2 }, { x = x_min_14, y = y_min_2 }, { x = x_min_13, y = y_min_2 }, { x = x_min_12, y = y_min_2 }, { x = x_min_11, y = y_min_2 }, { x = x_min_10, y = y_min_2 }, { x = x_min_9, y = y_min_2 }, { x = x_min_8, y = y_min_2 }, { x = x_min_7, y = y_min_2 }, { x = x_min_6, y = y_min_2 }, { x = x_min_5, y = y_min_2 }, { x = x_min_4, y = y_min_2 }, { x = x_min_3, y = y_min_2 }, { x = x_min_2, y = y_min_2 }, { x = x_min_1, y = y_min_2 }, { x = x_add_0, y = y_min_2 }, { x = x_add_1, y = y_min_2 }, { x = x_add_2, y = y_min_2 }, { x = x_add_3, y = y_min_2 }, { x = x_add_4, y = y_min_2 }, { x = x_add_5, y = y_min_2 }, { x = x_add_6, y = y_min_2 }, { x = x_add_7, y = y_min_2 }, { x = x_add_8, y = y_min_2 }, { x = x_add_9, y = y_min_2 }, { x = x_add_10, y = y_min_2 }, { x = x_add_11, y = y_min_2 }, { x = x_add_12, y = y_min_2 }, { x = x_add_13, y = y_min_2 }, { x = x_add_14, y = y_min_2 }, { x = x_add_15, y = y_min_2 }, { x = x_add_16, y = y_min_2 }, { x = x_min_16, y = y_min_1 }, { x = x_min_15, y = y_min_1 }, { x = x_min_14, y = y_min_1 }, { x = x_min_13, y = y_min_1 }, { x = x_min_12, y = y_min_1 }, { x = x_min_11, y = y_min_1 }, { x = x_min_10, y = y_min_1 }, { x = x_min_9, y = y_min_1 }, { x = x_min_8, y = y_min_1 }, { x = x_min_7, y = y_min_1 }, { x = x_min_6, y = y_min_1 }, { x = x_min_5, y = y_min_1 }, { x = x_min_4, y = y_min_1 }, { x = x_min_3, y = y_min_1 }, { x = x_min_2, y = y_min_1 }, { x = x_min_1, y = y_min_1 }, { x = x_add_0, y = y_min_1 }, { x = x_add_1, y = y_min_1 }, { x = x_add_2, y = y_min_1 }, { x = x_add_3, y = y_min_1 }, { x = x_add_4, y = y_min_1 }, { x = x_add_5, y = y_min_1 }, { x = x_add_6, y = y_min_1 }, { x = x_add_7, y = y_min_1 }, { x = x_add_8, y = y_min_1 }, { x = x_add_9, y = y_min_1 }, { x = x_add_10, y = y_min_1 }, { x = x_add_11, y = y_min_1 }, { x = x_add_12, y = y_min_1 }, { x = x_add_13, y = y_min_1 }, { x = x_add_14, y = y_min_1 }, { x = x_add_15, y = y_min_1 }, { x = x_add_16, y = y_min_1 }, { x = x_min_16, y = y_add_0 }, { x = x_min_15, y = y_add_0 }, { x = x_min_14, y = y_add_0 }, { x = x_min_13, y = y_add_0 }, { x = x_min_12, y = y_add_0 }, { x = x_min_11, y = y_add_0 }, { x = x_min_10, y = y_add_0 }, { x = x_min_9, y = y_add_0 }, { x = x_min_8, y = y_add_0 }, { x = x_min_7, y = y_add_0 }, { x = x_min_6, y = y_add_0 }, { x = x_min_5, y = y_add_0 }, { x = x_min_4, y = y_add_0 }, { x = x_min_3, y = y_add_0 }, { x = x_min_2, y = y_add_0 }, { x = x_min_1, y = y_add_0 }, { x = x_add_0, y = y_add_0 }, { x = x_add_1, y = y_add_0 }, { x = x_add_2, y = y_add_0 }, { x = x_add_3, y = y_add_0 }, { x = x_add_4, y = y_add_0 }, { x = x_add_5, y = y_add_0 }, { x = x_add_6, y = y_add_0 }, { x = x_add_7, y = y_add_0 }, { x = x_add_8, y = y_add_0 }, { x = x_add_9, y = y_add_0 }, { x = x_add_10, y = y_add_0 }, { x = x_add_11, y = y_add_0 }, { x = x_add_12, y = y_add_0 }, { x = x_add_13, y = y_add_0 }, { x = x_add_14, y = y_add_0 }, { x = x_add_15, y = y_add_0 }, { x = x_add_16, y = y_add_0 }, { x = x_min_16, y = y_add_1 }, { x = x_min_15, y = y_add_1 }, { x = x_min_14, y = y_add_1 }, { x = x_min_13, y = y_add_1 }, { x = x_min_12, y = y_add_1 }, { x = x_min_11, y = y_add_1 }, { x = x_min_10, y = y_add_1 }, { x = x_min_9, y = y_add_1 }, { x = x_min_8, y = y_add_1 }, { x = x_min_7, y = y_add_1 }, { x = x_min_6, y = y_add_1 }, { x = x_min_5, y = y_add_1 }, { x = x_min_4, y = y_add_1 }, { x = x_min_3, y = y_add_1 }, { x = x_min_2, y = y_add_1 }, { x = x_min_1, y = y_add_1 }, { x = x_add_0, y = y_add_1 }, { x = x_add_1, y = y_add_1 }, { x = x_add_2, y = y_add_1 }, { x = x_add_3, y = y_add_1 }, { x = x_add_4, y = y_add_1 }, { x = x_add_5, y = y_add_1 }, { x = x_add_6, y = y_add_1 }, { x = x_add_7, y = y_add_1 }, { x = x_add_8, y = y_add_1 }, { x = x_add_9, y = y_add_1 }, { x = x_add_10, y = y_add_1 }, { x = x_add_11, y = y_add_1 }, { x = x_add_12, y = y_add_1 }, { x = x_add_13, y = y_add_1 }, { x = x_add_14, y = y_add_1 }, { x = x_add_15, y = y_add_1 }, { x = x_add_16, y = y_add_1 }, { x = x_min_16, y = y_add_2 }, { x = x_min_15, y = y_add_2 }, { x = x_min_14, y = y_add_2 }, { x = x_min_13, y = y_add_2 }, { x = x_min_12, y = y_add_2 }, { x = x_min_11, y = y_add_2 }, { x = x_min_10, y = y_add_2 }, { x = x_min_9, y = y_add_2 }, { x = x_min_8, y = y_add_2 }, { x = x_min_7, y = y_add_2 }, { x = x_min_6, y = y_add_2 }, { x = x_min_5, y = y_add_2 }, { x = x_min_4, y = y_add_2 }, { x = x_min_3, y = y_add_2 }, { x = x_min_2, y = y_add_2 }, { x = x_min_1, y = y_add_2 }, { x = x_add_0, y = y_add_2 }, { x = x_add_1, y = y_add_2 }, { x = x_add_2, y = y_add_2 }, { x = x_add_3, y = y_add_2 }, { x = x_add_4, y = y_add_2 }, { x = x_add_5, y = y_add_2 }, { x = x_add_6, y = y_add_2 }, { x = x_add_7, y = y_add_2 }, { x = x_add_8, y = y_add_2 }, { x = x_add_9, y = y_add_2 }, { x = x_add_10, y = y_add_2 }, { x = x_add_11, y = y_add_2 }, { x = x_add_12, y = y_add_2 }, { x = x_add_13, y = y_add_2 }, { x = x_add_14, y = y_add_2 }, { x = x_add_15, y = y_add_2 }, { x = x_add_16, y = y_add_2 }, { x = x_min_16, y = y_add_3 }, { x = x_min_15, y = y_add_3 }, { x = x_min_14, y = y_add_3 }, { x = x_min_13, y = y_add_3 }, { x = x_min_12, y = y_add_3 }, { x = x_min_11, y = y_add_3 }, { x = x_min_10, y = y_add_3 }, { x = x_min_9, y = y_add_3 }, { x = x_min_8, y = y_add_3 }, { x = x_min_7, y = y_add_3 }, { x = x_min_6, y = y_add_3 }, { x = x_min_5, y = y_add_3 }, { x = x_min_4, y = y_add_3 }, { x = x_min_3, y = y_add_3 }, { x = x_min_2, y = y_add_3 }, { x = x_min_1, y = y_add_3 }, { x = x_add_0, y = y_add_3 }, { x = x_add_1, y = y_add_3 }, { x = x_add_2, y = y_add_3 }, { x = x_add_3, y = y_add_3 }, { x = x_add_4, y = y_add_3 }, { x = x_add_5, y = y_add_3 }, { x = x_add_6, y = y_add_3 }, { x = x_add_7, y = y_add_3 }, { x = x_add_8, y = y_add_3 }, { x = x_add_9, y = y_add_3 }, { x = x_add_10, y = y_add_3 }, { x = x_add_11, y = y_add_3 }, { x = x_add_12, y = y_add_3 }, { x = x_add_13, y = y_add_3 }, { x = x_add_14, y = y_add_3 }, { x = x_add_15, y = y_add_3 }, { x = x_add_16, y = y_add_3 }, { x = x_min_16, y = y_add_4 }, { x = x_min_15, y = y_add_4 }, { x = x_min_14, y = y_add_4 }, { x = x_min_13, y = y_add_4 }, { x = x_min_12, y = y_add_4 }, { x = x_min_11, y = y_add_4 }, { x = x_min_10, y = y_add_4 }, { x = x_min_9, y = y_add_4 }, { x = x_min_8, y = y_add_4 }, { x = x_min_7, y = y_add_4 }, { x = x_min_6, y = y_add_4 }, { x = x_min_5, y = y_add_4 }, { x = x_min_4, y = y_add_4 }, { x = x_min_3, y = y_add_4 }, { x = x_min_2, y = y_add_4 }, { x = x_min_1, y = y_add_4 }, { x = x_add_0, y = y_add_4 }, { x = x_add_1, y = y_add_4 }, { x = x_add_2, y = y_add_4 }, { x = x_add_3, y = y_add_4 }, { x = x_add_4, y = y_add_4 }, { x = x_add_5, y = y_add_4 }, { x = x_add_6, y = y_add_4 }, { x = x_add_7, y = y_add_4 }, { x = x_add_8, y = y_add_4 }, { x = x_add_9, y = y_add_4 }, { x = x_add_10, y = y_add_4 }, { x = x_add_11, y = y_add_4 }, { x = x_add_12, y = y_add_4 }, { x = x_add_13, y = y_add_4 }, { x = x_add_14, y = y_add_4 }, { x = x_add_15, y = y_add_4 }, { x = x_add_16, y = y_add_4 }, { x = x_min_16, y = y_add_5 }, { x = x_min_15, y = y_add_5 }, { x = x_min_14, y = y_add_5 }, { x = x_min_13, y = y_add_5 }, { x = x_min_12, y = y_add_5 }, { x = x_min_11, y = y_add_5 }, { x = x_min_10, y = y_add_5 }, { x = x_min_9, y = y_add_5 }, { x = x_min_8, y = y_add_5 }, { x = x_min_7, y = y_add_5 }, { x = x_min_6, y = y_add_5 }, { x = x_min_5, y = y_add_5 }, { x = x_min_4, y = y_add_5 }, { x = x_min_3, y = y_add_5 }, { x = x_min_2, y = y_add_5 }, { x = x_min_1, y = y_add_5 }, { x = x_add_0, y = y_add_5 }, { x = x_add_1, y = y_add_5 }, { x = x_add_2, y = y_add_5 }, { x = x_add_3, y = y_add_5 }, { x = x_add_4, y = y_add_5 }, { x = x_add_5, y = y_add_5 }, { x = x_add_6, y = y_add_5 }, { x = x_add_7, y = y_add_5 }, { x = x_add_8, y = y_add_5 }, { x = x_add_9, y = y_add_5 }, { x = x_add_10, y = y_add_5 }, { x = x_add_11, y = y_add_5 }, { x = x_add_12, y = y_add_5 }, { x = x_add_13, y = y_add_5 }, { x = x_add_14, y = y_add_5 }, { x = x_add_15, y = y_add_5 }, { x = x_add_16, y = y_add_5 }, { x = x_min_16, y = y_add_6 }, { x = x_min_15, y = y_add_6 }, { x = x_min_14, y = y_add_6 }, { x = x_min_13, y = y_add_6 }, { x = x_min_12, y = y_add_6 }, { x = x_min_11, y = y_add_6 }, { x = x_min_10, y = y_add_6 }, { x = x_min_9, y = y_add_6 }, { x = x_min_8, y = y_add_6 }, { x = x_min_7, y = y_add_6 }, { x = x_min_6, y = y_add_6 }, { x = x_min_5, y = y_add_6 }, { x = x_min_4, y = y_add_6 }, { x = x_min_3, y = y_add_6 }, { x = x_min_2, y = y_add_6 }, { x = x_min_1, y = y_add_6 }, { x = x_add_0, y = y_add_6 }, { x = x_add_1, y = y_add_6 }, { x = x_add_2, y = y_add_6 }, { x = x_add_3, y = y_add_6 }, { x = x_add_4, y = y_add_6 }, { x = x_add_5, y = y_add_6 }, { x = x_add_6, y = y_add_6 }, { x = x_add_7, y = y_add_6 }, { x = x_add_8, y = y_add_6 }, { x = x_add_9, y = y_add_6 }, { x = x_add_10, y = y_add_6 }, { x = x_add_11, y = y_add_6 }, { x = x_add_12, y = y_add_6 }, { x = x_add_13, y = y_add_6 }, { x = x_add_14, y = y_add_6 }, { x = x_add_15, y = y_add_6 }, { x = x_add_16, y = y_add_6 }, { x = x_min_16, y = y_add_7 }, { x = x_min_15, y = y_add_7 }, { x = x_min_14, y = y_add_7 }, { x = x_min_13, y = y_add_7 }, { x = x_min_12, y = y_add_7 }, { x = x_min_11, y = y_add_7 }, { x = x_min_10, y = y_add_7 }, { x = x_min_9, y = y_add_7 }, { x = x_min_8, y = y_add_7 }, { x = x_min_7, y = y_add_7 }, { x = x_min_6, y = y_add_7 }, { x = x_min_5, y = y_add_7 }, { x = x_min_4, y = y_add_7 }, { x = x_min_3, y = y_add_7 }, { x = x_min_2, y = y_add_7 }, { x = x_min_1, y = y_add_7 }, { x = x_add_0, y = y_add_7 }, { x = x_add_1, y = y_add_7 }, { x = x_add_2, y = y_add_7 }, { x = x_add_3, y = y_add_7 }, { x = x_add_4, y = y_add_7 }, { x = x_add_5, y = y_add_7 }, { x = x_add_6, y = y_add_7 }, { x = x_add_7, y = y_add_7 }, { x = x_add_8, y = y_add_7 }, { x = x_add_9, y = y_add_7 }, { x = x_add_10, y = y_add_7 }, { x = x_add_11, y = y_add_7 }, { x = x_add_12, y = y_add_7 }, { x = x_add_13, y = y_add_7 }, { x = x_add_14, y = y_add_7 }, { x = x_add_15, y = y_add_7 }, { x = x_add_16, y = y_add_7 }, { x = x_min_16, y = y_add_8 }, { x = x_min_15, y = y_add_8 }, { x = x_min_14, y = y_add_8 }, { x = x_min_13, y = y_add_8 }, { x = x_min_12, y = y_add_8 }, { x = x_min_11, y = y_add_8 }, { x = x_min_10, y = y_add_8 }, { x = x_min_9, y = y_add_8 }, { x = x_min_8, y = y_add_8 }, { x = x_min_7, y = y_add_8 }, { x = x_min_6, y = y_add_8 }, { x = x_min_5, y = y_add_8 }, { x = x_min_4, y = y_add_8 }, { x = x_min_3, y = y_add_8 }, { x = x_min_2, y = y_add_8 }, { x = x_min_1, y = y_add_8 }, { x = x_add_0, y = y_add_8 }, { x = x_add_1, y = y_add_8 }, { x = x_add_2, y = y_add_8 }, { x = x_add_3, y = y_add_8 }, { x = x_add_4, y = y_add_8 }, { x = x_add_5, y = y_add_8 }, { x = x_add_6, y = y_add_8 }, { x = x_add_7, y = y_add_8 }, { x = x_add_8, y = y_add_8 }, { x = x_add_9, y = y_add_8 }, { x = x_add_10, y = y_add_8 }, { x = x_add_11, y = y_add_8 }, { x = x_add_12, y = y_add_8 }, { x = x_add_13, y = y_add_8 }, { x = x_add_14, y = y_add_8 }, { x = x_add_15, y = y_add_8 }, { x = x_add_16, y = y_add_8 }, { x = x_min_16, y = y_add_9 }, { x = x_min_15, y = y_add_9 }, { x = x_min_14, y = y_add_9 }, { x = x_min_13, y = y_add_9 }, { x = x_min_12, y = y_add_9 }, { x = x_min_11, y = y_add_9 }, { x = x_min_10, y = y_add_9 }, { x = x_min_9, y = y_add_9 }, { x = x_min_8, y = y_add_9 }, { x = x_min_7, y = y_add_9 }, { x = x_min_6, y = y_add_9 }, { x = x_min_5, y = y_add_9 }, { x = x_min_4, y = y_add_9 }, { x = x_min_3, y = y_add_9 }, { x = x_min_2, y = y_add_9 }, { x = x_min_1, y = y_add_9 }, { x = x_add_0, y = y_add_9 }, { x = x_add_1, y = y_add_9 }, { x = x_add_2, y = y_add_9 }, { x = x_add_3, y = y_add_9 }, { x = x_add_4, y = y_add_9 }, { x = x_add_5, y = y_add_9 }, { x = x_add_6, y = y_add_9 }, { x = x_add_7, y = y_add_9 }, { x = x_add_8, y = y_add_9 }, { x = x_add_9, y = y_add_9 }, { x = x_add_10, y = y_add_9 }, { x = x_add_11, y = y_add_9 }, { x = x_add_12, y = y_add_9 }, { x = x_add_13, y = y_add_9 }, { x = x_add_14, y = y_add_9 }, { x = x_add_15, y = y_add_9 }, { x = x_add_16, y = y_add_9 }, { x = x_min_16, y = y_add_10 }, { x = x_min_15, y = y_add_10 }, { x = x_min_14, y = y_add_10 }, { x = x_min_13, y = y_add_10 }, { x = x_min_12, y = y_add_10 }, { x = x_min_11, y = y_add_10 }, { x = x_min_10, y = y_add_10 }, { x = x_min_9, y = y_add_10 }, { x = x_min_8, y = y_add_10 }, { x = x_min_7, y = y_add_10 }, { x = x_min_6, y = y_add_10 }, { x = x_min_5, y = y_add_10 }, { x = x_min_4, y = y_add_10 }, { x = x_min_3, y = y_add_10 }, { x = x_min_2, y = y_add_10 }, { x = x_min_1, y = y_add_10 }, { x = x_add_0, y = y_add_10 }, { x = x_add_1, y = y_add_10 }, { x = x_add_2, y = y_add_10 }, { x = x_add_3, y = y_add_10 }, { x = x_add_4, y = y_add_10 }, { x = x_add_5, y = y_add_10 }, { x = x_add_6, y = y_add_10 }, { x = x_add_7, y = y_add_10 }, { x = x_add_8, y = y_add_10 }, { x = x_add_9, y = y_add_10 }, { x = x_add_10, y = y_add_10 }, { x = x_add_11, y = y_add_10 }, { x = x_add_12, y = y_add_10 }, { x = x_add_13, y = y_add_10 }, { x = x_add_14, y = y_add_10 }, { x = x_add_15, y = y_add_10 }, { x = x_add_16, y = y_add_10 }, { x = x_min_16, y = y_add_11 }, { x = x_min_15, y = y_add_11 }, { x = x_min_14, y = y_add_11 }, { x = x_min_13, y = y_add_11 }, { x = x_min_12, y = y_add_11 }, { x = x_min_11, y = y_add_11 }, { x = x_min_10, y = y_add_11 }, { x = x_min_9, y = y_add_11 }, { x = x_min_8, y = y_add_11 }, { x = x_min_7, y = y_add_11 }, { x = x_min_6, y = y_add_11 }, { x = x_min_5, y = y_add_11 }, { x = x_min_4, y = y_add_11 }, { x = x_min_3, y = y_add_11 }, { x = x_min_2, y = y_add_11 }, { x = x_min_1, y = y_add_11 }, { x = x_add_0, y = y_add_11 }, { x = x_add_1, y = y_add_11 }, { x = x_add_2, y = y_add_11 }, { x = x_add_3, y = y_add_11 }, { x = x_add_4, y = y_add_11 }, { x = x_add_5, y = y_add_11 }, { x = x_add_6, y = y_add_11 }, { x = x_add_7, y = y_add_11 }, { x = x_add_8, y = y_add_11 }, { x = x_add_9, y = y_add_11 }, { x = x_add_10, y = y_add_11 }, { x = x_add_11, y = y_add_11 }, { x = x_add_12, y = y_add_11 }, { x = x_add_13, y = y_add_11 }, { x = x_add_14, y = y_add_11 }, { x = x_add_15, y = y_add_11 }, { x = x_add_16, y = y_add_11 }, { x = x_min_16, y = y_add_12 }, { x = x_min_15, y = y_add_12 }, { x = x_min_14, y = y_add_12 }, { x = x_min_13, y = y_add_12 }, { x = x_min_12, y = y_add_12 }, { x = x_min_11, y = y_add_12 }, { x = x_min_10, y = y_add_12 }, { x = x_min_9, y = y_add_12 }, { x = x_min_8, y = y_add_12 }, { x = x_min_7, y = y_add_12 }, { x = x_min_6, y = y_add_12 }, { x = x_min_5, y = y_add_12 }, { x = x_min_4, y = y_add_12 }, { x = x_min_3, y = y_add_12 }, { x = x_min_2, y = y_add_12 }, { x = x_min_1, y = y_add_12 }, { x = x_add_0, y = y_add_12 }, { x = x_add_1, y = y_add_12 }, { x = x_add_2, y = y_add_12 }, { x = x_add_3, y = y_add_12 }, { x = x_add_4, y = y_add_12 }, { x = x_add_5, y = y_add_12 }, { x = x_add_6, y = y_add_12 }, { x = x_add_7, y = y_add_12 }, { x = x_add_8, y = y_add_12 }, { x = x_add_9, y = y_add_12 }, { x = x_add_10, y = y_add_12 }, { x = x_add_11, y = y_add_12 }, { x = x_add_12, y = y_add_12 }, { x = x_add_13, y = y_add_12 }, { x = x_add_14, y = y_add_12 }, { x = x_add_15, y = y_add_12 }, { x = x_add_16, y = y_add_12 }, { x = x_min_16, y = y_add_13 }, { x = x_min_15, y = y_add_13 }, { x = x_min_14, y = y_add_13 }, { x = x_min_13, y = y_add_13 }, { x = x_min_12, y = y_add_13 }, { x = x_min_11, y = y_add_13 }, { x = x_min_10, y = y_add_13 }, { x = x_min_9, y = y_add_13 }, { x = x_min_8, y = y_add_13 }, { x = x_min_7, y = y_add_13 }, { x = x_min_6, y = y_add_13 }, { x = x_min_5, y = y_add_13 }, { x = x_min_4, y = y_add_13 }, { x = x_min_3, y = y_add_13 }, { x = x_min_2, y = y_add_13 }, { x = x_min_1, y = y_add_13 }, { x = x_add_0, y = y_add_13 }, { x = x_add_1, y = y_add_13 }, { x = x_add_2, y = y_add_13 }, { x = x_add_3, y = y_add_13 }, { x = x_add_4, y = y_add_13 }, { x = x_add_5, y = y_add_13 }, { x = x_add_6, y = y_add_13 }, { x = x_add_7, y = y_add_13 }, { x = x_add_8, y = y_add_13 }, { x = x_add_9, y = y_add_13 }, { x = x_add_10, y = y_add_13 }, { x = x_add_11, y = y_add_13 }, { x = x_add_12, y = y_add_13 }, { x = x_add_13, y = y_add_13 }, { x = x_add_14, y = y_add_13 }, { x = x_add_15, y = y_add_13 }, { x = x_add_16, y = y_add_13 }, { x = x_min_16, y = y_add_14 }, { x = x_min_15, y = y_add_14 }, { x = x_min_14, y = y_add_14 }, { x = x_min_13, y = y_add_14 }, { x = x_min_12, y = y_add_14 }, { x = x_min_11, y = y_add_14 }, { x = x_min_10, y = y_add_14 }, { x = x_min_9, y = y_add_14 }, { x = x_min_8, y = y_add_14 }, { x = x_min_7, y = y_add_14 }, { x = x_min_6, y = y_add_14 }, { x = x_min_5, y = y_add_14 }, { x = x_min_4, y = y_add_14 }, { x = x_min_3, y = y_add_14 }, { x = x_min_2, y = y_add_14 }, { x = x_min_1, y = y_add_14 }, { x = x_add_0, y = y_add_14 }, { x = x_add_1, y = y_add_14 }, { x = x_add_2, y = y_add_14 }, { x = x_add_3, y = y_add_14 }, { x = x_add_4, y = y_add_14 }, { x = x_add_5, y = y_add_14 }, { x = x_add_6, y = y_add_14 }, { x = x_add_7, y = y_add_14 }, { x = x_add_8, y = y_add_14 }, { x = x_add_9, y = y_add_14 }, { x = x_add_10, y = y_add_14 }, { x = x_add_11, y = y_add_14 }, { x = x_add_12, y = y_add_14 }, { x = x_add_13, y = y_add_14 }, { x = x_add_14, y = y_add_14 }, { x = x_add_15, y = y_add_14 }, { x = x_add_16, y = y_add_14 }, { x = x_min_16, y = y_add_15 }, { x = x_min_15, y = y_add_15 }, { x = x_min_14, y = y_add_15 }, { x = x_min_13, y = y_add_15 }, { x = x_min_12, y = y_add_15 }, { x = x_min_11, y = y_add_15 }, { x = x_min_10, y = y_add_15 }, { x = x_min_9, y = y_add_15 }, { x = x_min_8, y = y_add_15 }, { x = x_min_7, y = y_add_15 }, { x = x_min_6, y = y_add_15 }, { x = x_min_5, y = y_add_15 }, { x = x_min_4, y = y_add_15 }, { x = x_min_3, y = y_add_15 }, { x = x_min_2, y = y_add_15 }, { x = x_min_1, y = y_add_15 }, { x = x_add_0, y = y_add_15 }, { x = x_add_1, y = y_add_15 }, { x = x_add_2, y = y_add_15 }, { x = x_add_3, y = y_add_15 }, { x = x_add_4, y = y_add_15 }, { x = x_add_5, y = y_add_15 }, { x = x_add_6, y = y_add_15 }, { x = x_add_7, y = y_add_15 }, { x = x_add_8, y = y_add_15 }, { x = x_add_9, y = y_add_15 }, { x = x_add_10, y = y_add_15 }, { x = x_add_11, y = y_add_15 }, { x = x_add_12, y = y_add_15 }, { x = x_add_13, y = y_add_15 }, { x = x_add_14, y = y_add_15 }, { x = x_add_15, y = y_add_15 }, { x = x_add_16, y = y_add_15 }, { x = x_min_16, y = y_add_16 }, { x = x_min_15, y = y_add_16 }, { x = x_min_14, y = y_add_16 }, { x = x_min_13, y = y_add_16 }, { x = x_min_12, y = y_add_16 }, { x = x_min_11, y = y_add_16 }, { x = x_min_10, y = y_add_16 }, { x = x_min_9, y = y_add_16 }, { x = x_min_8, y = y_add_16 }, { x = x_min_7, y = y_add_16 }, { x = x_min_6, y = y_add_16 }, { x = x_min_5, y = y_add_16 }, { x = x_min_4, y = y_add_16 }, { x = x_min_3, y = y_add_16 }, { x = x_min_2, y = y_add_16 }, { x = x_min_1, y = y_add_16 }, { x = x_add_0, y = y_add_16 }, { x = x_add_1, y = y_add_16 }, { x = x_add_2, y = y_add_16 }, { x = x_add_3, y = y_add_16 }, { x = x_add_4, y = y_add_16 }, { x = x_add_5, y = y_add_16 }, { x = x_add_6, y = y_add_16 }, { x = x_add_7, y = y_add_16 }, { x = x_add_8, y = y_add_16 }, { x = x_add_9, y = y_add_16 }, { x = x_add_10, y = y_add_16 }, { x = x_add_11, y = y_add_16 }, { x = x_add_12, y = y_add_16 }, { x = x_add_13, y = y_add_16 }, { x = x_add_14, y = y_add_16 }, { x = x_add_15, y = y_add_16 }, { x = x_add_16, y = y_add_16 },
        }
    end
end

--[[
to generate the huge tables for each step count, run the following command in chat console:
/c
local function generatePatternStrings(startX, startY)
    local patternStrings = {}
    for y = startY, startY + math.abs(startY) * 2 do
        for x = startX, startX + math.abs(startX) * 2 do
        local patternString = "{x = x_" .. (x >= 0 and "add_" or "min_") .. math.abs(x) .. ", y = y_" .. (y >= 0 and "add_" or "min_") .. math.abs(y) .. "},"
        table.insert(patternStrings, patternString)
        end
    end
    return patternStrings
end
log(table.concat(generatePatternStrings(-16, -16)))
--]]

local function get_area_of_quad(quad_position, quad_size)
    local area = {
        left_top = quad_position,
        right_bottom = {
            x = quad_position.x + quad_size,
            y = quad_position.y + quad_size,
        }
    }
    return area
end

local function get_middle_of_quad(quad_position, quad_size)
    local middle = {
        x = quad_position.x + quad_size / 2,
        y = quad_position.y + quad_size / 2,
    }
    return middle
end

local function draw_rectangle(surface, area, color)
    rendering.draw_rectangle {
        color = color,
        filled = false,
        left_top = area.left_top,
        right_bottom = area.right_bottom,
        surface = surface,
        time_to_live = 60,
    }
end

local function draw_text(surface, position, text, color, scale, time_to_live)
    time_to_live = time_to_live or (60 * 20)
    rendering.draw_text {
        color = color,
        text = text,
        surface = surface,
        target = position,
        time_to_live = time_to_live,
        scale = scale,
    }
end

local function average_tree_stage_index(trees)
    local tree_stage_index = 0
    for _, tree in pairs(trees) do
        tree_stage_index = tree_stage_index + tree.tree_stage_index
    end
    return tree_stage_index / #trees
end

local function normalize_value(value, minimum, maximum)
    return (value - minimum) / (maximum - minimum)
end

local function round(number, round_to)
    round_to = round_to or 1
    local multiplier = 10 ^ round_to -- i.e. 10 raised to the power of 3 (3 decimal places)
    return math.floor(number * multiplier + 0.5) / multiplier
end

---get the current player position, or the position of the last known selected entity if the player is zoomed in on map mode
---@param player LuaPlayer
---@return MapPosition
local function get_position(player)
    local position = player.position
    if player.render_mode == defines.render_mode.chart_zoomed_in then
        if player.selected then
            position = player.selected.position
        elseif storage.last_known_selected_entity_position and storage.last_known_selected_entity_position[player.index] then
            position = storage.last_known_selected_entity_position[player.index]
        end
    end
    return position
end

---@class group_settings
---@field light_scale string|number
---@field color_mode string
---@field brightness_value string|number
---@field step_count string|number
---@field players LuaPlayer[]

-- return a table with the players sorted into groups based on if they have the same settings
---@param connected_players LuaPlayer[]
---@return table<string, group_settings>
local function unique_groups(connected_players)
    local groups = {}
    local game_settings = settings.global
    for _, player in pairs(connected_players) do
        local mod_settings = player.mod_settings
        local light_scale = light_scales[mod_settings["glow_aura_scale"].value]
        local color_mode = mod_settings["glow_aura_color_mode"].value
        local brightness_value = brightness[mod_settings["glow_aura_brightness"].value]
        local step_count = step_counts[mod_settings["glow_aura_step_count"].value]
        -- local group_name = format("%s_%s_%s_%s", light_scale, color_mode, brightness_value, step_count)
        if light_scale == "sync" then light_scale = light_scales[game_settings["global_glow_aura_scale"].value] end
        if color_mode == "sync" then color_mode = game_settings["global_glow_aura_color_mode"].value end
        if brightness_value == "sync" then brightness_value = brightness[game_settings["global_glow_aura_brightness"].value] end
        if step_count == "sync" then step_count = step_counts[game_settings["global_glow_aura_step_count"].value] end
        local group_name = format("%d_%.2f_%s", light_scale, brightness_value, color_mode)
        groups[group_name] = groups[group_name] or {}
        groups[group_name].light_scale = groups[group_name].light_scale or light_scale
        groups[group_name].color_mode = groups[group_name].color_mode or color_mode
        groups[group_name].brightness_value = groups[group_name].brightness_value or brightness_value
        groups[group_name].step_count = groups[group_name].step_count or step_count
        groups[group_name].players = groups[group_name].players or {}
        insert(groups[group_name].players, player)
    end
    return groups
end

---@param event NthTickEventData
local function on_nth_tick(event)
    local time_to_live = 60 * 30
    local intensity = 0.1
    local step_length = 16
    local nth_tick = event.nth_tick
    local event_tick = event.tick
    local draw_rectangles = storage.draw_rectangles or false
    storage.quads_with_lights_by_uuid = storage.quads_with_lights_by_uuid or {}
    local quads_with_lights_by_uuid = storage.quads_with_lights_by_uuid
    storage.quads_with_no_trees_by_uuid = storage.quads_with_no_trees_by_uuid or {}
    local quads_with_no_trees_by_uuid = storage.quads_with_no_trees_by_uuid
    local connected_players = game.connected_players
    for uuid, quad_data in pairs(quads_with_lights_by_uuid) do
        local expire_tick = quad_data.expire_tick
        if expire_tick <= event_tick then
            quads_with_lights_by_uuid[uuid] = nil
        end
    end
    for uuid, quad_data in pairs(quads_with_no_trees_by_uuid) do
        local expire_tick = quad_data.expire_tick
        if expire_tick <= event_tick then
            quads_with_no_trees_by_uuid[uuid] = nil
        end
    end
    local groups = unique_groups(connected_players)
    for group_name, group in pairs(groups) do
        local color_mode = group.color_mode
        if color_mode == "none" then goto next_group end
        local light_scale = group.light_scale
        local brightness_value = group.brightness_value
        local step_count = group.step_count
        local steps = step_count / step_length
        local players = group.players
        for _, player in pairs(players) do
            local surface = player.surface
            local surface_index = surface.index
            -- local player_position = get_position(player)
            local player_position = player.position
            local player_surface_key = format("%s_%d", group_name, surface_index)
            local quad_positions = get_surrounding_chunk_positions(player_position, steps, step_length)
            for _, quad_position in pairs(quad_positions) do
                local x = quad_position.x
                local y = quad_position.y
                local quad_uuid = format("%s, %d, %d", player_surface_key, x, y)
                if draw_rectangles then
                    draw_text(surface, quad_position, quad_uuid, { r = 1, g = 0, b = 1, a = 1 }, 1)
                end
                local quad_has_existing_light = false
                local quad_has_no_trees = false
                local quad_data = nil
                if quads_with_lights_by_uuid and quads_with_lights_by_uuid[quad_uuid] then
                    quad_has_existing_light = true
                    quad_data = quads_with_lights_by_uuid[quad_uuid]
                end
                if quads_with_no_trees_by_uuid and quads_with_no_trees_by_uuid[quad_uuid] then
                    quad_has_no_trees = true
                    quad_data = quads_with_no_trees_by_uuid[quad_uuid]
                end
                local quad_is_new = not quad_has_existing_light and not quad_has_no_trees
                local quad_with_light_needs_update = quad_has_existing_light and (quad_data.expire_tick < event_tick + 60)
                local quad_with_no_trees_needs_update = quad_has_no_trees and (quad_data.expire_tick < event_tick + 60)
                if quad_is_new then
                    if not surface.is_chunk_generated({ x / 32, y / 32 }) then
                        if draw_rectangles then
                            draw_text(surface, { x, y + 2 }, "not generated", { r = 1, g = 0.5, b = 0.5, a = 1 }, 3, nth_tick + 10)
                        end
                        goto next_quad
                    end
                end
                if quad_with_light_needs_update then
                    if quad_data.expire_tick < event_tick + 60 then
                        local modified_time_to_live = time_to_live + random(1, 120)
                        quad_data.light.time_to_live = modified_time_to_live
                        quads_with_no_trees_by_uuid[quad_uuid] = nil
                        quads_with_lights_by_uuid[quad_uuid].expire_tick = event_tick + modified_time_to_live
                        if draw_rectangles then
                            draw_rectangle(surface, get_area_of_quad(quad_position, step_length), { r = 0, g = 0, b = 1, a = 1 })
                        end
                    end
                elseif quad_with_no_trees_needs_update or quad_is_new then
                    local area = get_area_of_quad(quad_position, step_length)
                    local trees = surface.find_entities_filtered {
                        area = area,
                        type = { "tree", "plant" },
                    }
                    local number_of_trees = #trees
                    if number_of_trees > 1 then
                        local quad_midpoint = get_middle_of_quad(quad_position, step_length)
                        local tree_positions = {}
                        for count, tree in pairs(trees) do
                            insert(tree_positions, tree.position)
                            if not (count % 5) then insert(tree_positions, quad_midpoint) end
                        end
                        insert(tree_positions, quad_midpoint)
                        local average_tree_position = average_position(tree_positions)
                        local modified_time_to_live = time_to_live + random(1, 120)

                        local frequency = 0.0125
                        local color = color_modes[color_mode](x, y, number_of_trees, frequency, surface)

                        color = normalize_color(color, brightness_value)
                        intensity = 0.4 + min(normalize_value(number_of_trees, 1, 32), 0.6)

                        local light = rendering.draw_light {
                            sprite = "utility/light_medium",
                            scale = light_scale,
                            intensity = intensity,
                            color = color,
                            target = average_tree_position,
                            surface = surface,
                            time_to_live = modified_time_to_live,
                            players = players,
                        }
                        quads_with_no_trees_by_uuid[quad_uuid] = nil
                        quads_with_lights_by_uuid[quad_uuid] = {
                            expire_tick = event_tick + modified_time_to_live,
                            light = light,
                        }
                        if draw_rectangles then
                            draw_rectangle(surface, area, { r = 1, g = 1, b = 1, a = 1 })
                            draw_text(surface, average_tree_position, round(intensity, 3), color, 5)
                        end
                    else
                        quads_with_lights_by_uuid[quad_uuid] = nil
                        quads_with_no_trees_by_uuid[quad_uuid] = {
                            expire_tick = event_tick + floor((time_to_live + random(1, 120)) * 1.25),
                        }
                        if draw_rectangles then
                            draw_rectangle(surface, area, { r = 0, g = 1, b = 0, a = 1 })
                        end
                    end
                end
                ::next_quad::
            end
        end
        ::next_group::
    end
end

---@class quad_with_light_data
---@field expire_tick number
---@field light LuaRenderObject?

local function mod_settings_changed()
    ---@type table<string, quad_with_light_data>
    storage.quads_with_lights_by_uuid = {}
    ---@type table<string, quad_with_light_data>
    storage.quads_with_no_trees_by_uuid = {}
    rendering.clear("glowing_trees")
end

local function toggle_debug_mode()
    storage.draw_rectangles = not storage.draw_rectangles
    if storage.draw_rectangles then
        game.print("Glowing Trees: Debug mode enabled")
    else
        game.print("Glowing Trees: Debug mode disabled")
    end
    mod_settings_changed()
end

local function add_commands()
    commands.add_command("glowingdebug", "- toggles debug mode to visualize what the glowing trees algorithm is doing", toggle_debug_mode)
end

---when selected entity changes and the player is in zoomed in map view, save the entity position to global to use as position for drawing glow auras on_nth_tick
---@param event EventData.on_selected_entity_changed
local function selected_entity_changed(event)
    local player_index = event.player_index
    local player = game.get_player(player_index)
    if player and (player.render_mode == defines.render_mode.chart_zoomed_in) then
        -- on_nth_tick({tick = event.tick, nth_tick = 10})
        if not storage.last_known_selected_entity_position then storage.last_known_selected_entity_position = {} end
        local entity = event.last_entity
        if player.selected then entity = player.selected end
        if entity and entity.position then storage.last_known_selected_entity_position[player_index] = entity.position end
    end
end

-- script.on_event(defines.events.on_selected_entity_changed, selected_entity_changed)

local function reset_storage()
    storage = {}
end

script.on_configuration_changed(function()
    reset_storage()
end)

script.on_nth_tick(10, on_nth_tick)

script.on_event(defines.events.on_runtime_mod_setting_changed, mod_settings_changed)

script.on_init(function()
    add_commands()
end)

script.on_load(function()
    add_commands()
end)
