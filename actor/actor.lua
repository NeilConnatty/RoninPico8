-- generic actor code -- manages drawing & collisions

local actors = {}

local function _create_actor(animations, palate, x, y, w, h, speed, parent, on_update, on_cant_move, on_sword_collision, post_draw)
    local new_actor = {
        animations = animations,
        palate = palate,
        flip_x = false,
        -- position in tile coordinates
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        speed = speed,
        -- hitbox in pixel size
        w = w,
        h = h,
        parent = parent,
        enabled = true,
        on_update = on_update,
        on_cant_move = on_cant_move,
        on_sword_collision = on_sword_collision,
        post_draw = post_draw
    }

    add(actors, new_actor)
    return new_actor
end

function create_actor(options)
    assert(options.animations != nil, "create_actor called with no animation")
    assert(options.x != nil and options.y != nil, "create_actor called with no position")
    assert(options.parent != nil, "create_actor called with no parent")
    assert(options.on_update != nil, "create_actor called with no update function")

    return _create_actor(
        options.animations, 
        options.palate or {}, -- default no palate swap
        options.x, 
        options.y,
        options.w or 8,
        options.h or 8,
        options.speed or 0.125,
        options.parent,
        options.on_update,
        options.on_cant_move, -- nil default
        options.on_sword_collision, -- nil default
        options.post_draw -- nil default
    )
end

local function actor_on_screen(actor)
    local mapx, mapy = get_map_pos()
    local x, y = actor.x, actor.y
    if (x < mapx or x > mapx+15 or y < mapy or y > mapy+15) then 
        return false
    end
    return true
end

local function draw_actor(actor)
    if not actor.enabled then return end 
    if not actor_on_screen(actor) then return end
    
    pal(actor.palate, 0)
    foreach(actor.animations, function (animation)
        spr(get_current_sprite(animation), flr(actor.x*8), flr(actor.y*8), 1, 1, actor.flip_x, false)
    end)
    pal(0)
    if (actor.post_draw) actor.post_draw(actor.parent)
end

function draw_actors()
    foreach(actors, draw_actor)
end

local function point_inside(x1, y1, x2, y2, w2, h2)
    if  x1 >= x2 and x1 <= x2+w2
    and y1 >= y2 and y1 <= y2+h2 then
        return true
    end
end

function check_collision(actor1, actor2)
    local x1,y1 = actor1.x*8, actor1.y*8
    local w1, h1 = actor1.w-1, actor1.h-1 -- -1, like in 0-indexed arrays
    local x2,y2 = actor2.x*8, actor2.y*8
    local w2, h2 = actor2.w-1, actor2.h-1

    return point_inside(x1, y1, x2, y2, w2, h2) 
        or point_inside(x1, y1+h1, x2, y2, w2, h2)
        or point_inside(x1+w1, y1, x2, y2, w2, h2)
        or point_inside(x1+w1, y1+h1, x2, y2, w2, h2)
end

function point_inside_actor(x, y, actor)
    local x2,y2 = actor.x*8, actor.y*8
    local w2, h2 = actor.w-1, actor.h-1
    if point_inside(x, y, x2, y2, w2, h2) then
        return true
    end
    return false
end
    
function for_each_actor(func)
    foreach(actors, func)
end

-- x, y in pixel coords
-- callback can be nil
local function check_point_collisions(x, y)
    for i=1,#actors do
        local actor = actors[i]
        if (actor.enabled) then
            if (point_inside_actor(x, y, actor)) then 
                return true
            end
        end
    end
    return false
end

local function can_move(x,y) -- x y are in pixel coords
	if (is_tile(sprite_flags.wall,x,y)) return false
    --if (check_point_collisions(x, y)) return false -- not working for some reason :shrug:
    return true
end

local function move_actor(actor)
    if not actor.enabled then 
        return 
    end

    if actor.dx == 0 and actor.dy == 0 then 
        return 
    end

    local dx, dy = normalize(actor.dx, actor.dy)
    local newx = actor.x + (dx*actor.speed)
    local newy = actor.y + (dy*actor.speed)

    -- check can_move for all four corners of the sprite
    -- ideally p.x & p.y are in pixel coordinates, not tile.. oh well
    if  can_move(newx,newy)
    and can_move(newx,newy+0.875)
    and can_move(newx+0.875,newy)
    and can_move(newx+0.875,newy+0.875) then
		actor.x=mid(0,newx,127)
		actor.y=mid(0,newy,63)
	else
        if (actor.on_cant_move) actor.on_cant_move(actor.parent)
	end
end

function move_actors()
    foreach(actors, move_actor)
end

local function update_actor(actor)
    if not actor.enabled then return end 
    if not actor_on_screen(actor) then return end

    actor.on_update(actor.parent)
    if (actor.dx != 0 or actor.dy != 0) then
        foreach(actor.animations, update_animation)
    else 
        foreach(actor.animations, 
        function(animation) 
            animation.curr_frame_time = 0
            animation.curr_sprite = 1
        end)
    end
end

function update_actors()
    foreach(actors, update_actor)
end
