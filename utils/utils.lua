
function normalize(x, y)
    local x_2, y_2 = x*x, y*y
    local length = sqrt(x_2 + y_2)
    return x / length, y / length
end

function rotate90(x, y)
    return -1*y, x
end

function rotate180(x, y)
    return -1*x, -1*y
end

function rotate270(x, y)
    return y, -1*x
end
