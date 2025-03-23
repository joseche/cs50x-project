local utils = {}

function utils.get_last_n_items(tbl, n)
    local result = {}
    local count = #tbl
    local start = math.max(count - n + 1, 1)
    for i = start, count do
        table.insert(result, tbl[i])
    end
    return result
end

function utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for word in string.gmatch(str, pattern) do
        table.insert(result, word)
    end
    return result
end

function utils.pretty_print(table, indent)
    indent = indent or 0                    -- Default indentation level
    local spaces = string.rep("  ", indent) -- Create indentation spaces

    for key, value in pairs(table) do
        if type(value) == "table" then
            -- If the value is a table, recursively pretty-print it
            print(spaces .. tostring(key) .. ":")
            utils.pretty_print(value, indent + 1) -- Increase indentation for nested tables
        else
            -- Otherwise, print the key and value
            print(spaces .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function utils.rating_round_down(rating)
    return math.floor(rating / RatingRoundingFactor) * RatingRoundingFactor
end

function utils.rating_round_up(rating)
    return math.ceil(rating / RatingRoundingFactor) * RatingRoundingFactor
end

return utils
