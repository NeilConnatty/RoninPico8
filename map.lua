--map code

local sprite_flags = {
    background = 1,
    foreground = 2,
    wall = 4,
    -- 8
    -- 16
    -- 32
    -- 64
    -- 128
    -- 256
}

function init_map()
    -- check each tile on map
    -- if enemy, then spawn enemy
    printh("init_map")
    for i = 0,127 do
        for j = 0,63 do
            if (mget(i,j) == 16) then
                printh("found enemy to spawn at "..i..","..j)
                create_enemy(i,j)
                mset(i,j,0)
            end
        end
    end
end

function update_map()
    -- stub
end

function get_map_pos()
    local x,y = get_player_pos()
	local mapx=flr(x/16)*16
	local mapy=flr(y/16)*16
    return mapx, mapy
end

local function draw_map(flag)
    mapx, mapy = get_map_pos()
	camera(mapx*8,mapy*8)
	map(0,0,0,0,128,64, flag)
end

function draw_background()
	draw_map(sprite_flags.background)
end

function draw_foreground()
    draw_map(sprite_flags.foreground)
end

function is_tile(tile_type,x,y)
	tile=mget(x,y)
	flags=fget(tile)
	return (flags & tile_type) == tile_type
end
