
directions = {
    up = 0,
    down = 1,
    left = 2,
    right = 3
}

function create_sword()
    local new_sword = {
        direction = directions.up,
        frame = 1,
    }
    return new_sword
end

local sword_frames = {
    -- first four frames moving up
    {
        x0 = 8,
        y0 = 4,
        x1 = 12,
        y1 = 4
    },
    {
        x0 = 8,
        y0 = 3,
        x1 = 12,
        y1 = 3
    },
    {
        x0 = 8,
        y0 = 2,
        x1 = 12,
        y1 = 2
    },
    {
        x0 = 8,
        y0 = 1,
        x1 = 12,
        y1 = 1
    },
    -- next follow curve diagonal
    {
        x0 = 8,
        y0 = 0,
        x1 = 11,
        y1 = -3
    },
    {
        x0 = 7,
        y0 = -1,
        x1 = 10,
        y1 = -4
    },
    {
        x0 = 6,
        y0 = -2,
        x1 = 9,
        y1 = -5
    },
    -- now move vertically over head
    {
        x0 = 5,
        y0 = -2,
        x1 = 5,
        y1 = -6
    },
    {
        x0 = 4,
        y0 = -2,
        x1 = 4,
        y1 = -6
    },
    {
        x0 = 3,
        y0 = -2,
        x1 = 3,
        y1 = -6
    },
    {
        x0 = 2,
        y0 = -2,
        x1 = 2,
        y1 = -6
    },
    {
        x0 = 1,
        y0 = -2,
        x1 = 1,
        y1 = -6
    },
    -- one last frame of follow-through
    {
        x0 = 0,
        y0 = -2,
        x1 = -3,
        y1 = -5
    }
}

local computed_swords = {}

local function init_sword_frame(frame)
    local new_frame_up = {
        x0 = frame.x0, y0 = frame.y0,
        x1 = frame.x1, y1 = frame.y1
    } 
    add(computed_swords[directions.up], frame)

    local new_frame_left = {}
    new_frame_left.x0, new_frame_left.y0 = rotate270(frame.x0, frame.y0)
    new_frame_left.x1, new_frame_left.y1 = rotate270(frame.x1, frame.y1)
    add(computed_swords[directions.left], new_frame_left)

    local new_frame_down = {}
    new_frame_down.x0, new_frame_down.y0 = rotate180(frame.x0, frame.y0)
    new_frame_down.x1, new_frame_down.y1 = rotate180(frame.x1, frame.y1)
    add(computed_swords[directions.down], new_frame_down)

    local new_frame_right = {}
    new_frame_right.x0, new_frame_right.y0 = rotate90(frame.x0, frame.y0)
    new_frame_right.x1, new_frame_right.y1 = rotate90(frame.x1, frame.y1)
    add(computed_swords[directions.right], new_frame_right)
end

function init_swords()
    computed_swords[directions.up] = {}
    computed_swords[directions.left] = {}
    computed_swords[directions.down] = {}
    computed_swords[directions.right] = {}
    foreach(sword_frames, init_sword_frame)
end

function draw_sword(sword, actor)
    local x,y = actor.x*8, actor.y*8
    if      (sword.direction == directions.left) then x,y = x,y+7
    elseif  (sword.direction == directions.down) then x,y = x+7,y+7
    elseif  (sword.direction == directions.right) then x,y = x+7,y end
    
    local sword_frame = computed_swords[sword.direction][sword.frame]
    local x0, y0 = sword_frame.x0+x, sword_frame.y0+y
    local x1, y1 = sword_frame.x1+x, sword_frame.y1+y

    line(x0, y0, x1, y1, 7)
end

function check_sword_collisions(sword, owner)
    local x,y = owner.x*8, owner.y*8
    if      (sword.direction == directions.left) then x,y = x,y+7
    elseif  (sword.direction == directions.down) then x,y = x+7,y+7
    elseif  (sword.direction == directions.right) then x,y = x+7,y end
    
    local sword_frame = computed_swords[sword.direction][sword.frame]
    local x1, y1 = sword_frame.x1+x, sword_frame.y1+y

    for_each_actor(
        function (actor)
            if (actor.enabled and actor.on_sword_collision != nil) then
                if (point_inside_actor(x1, y1, actor)) then
                    actor.on_sword_collision(actor.parent)
                end
            end
        end
    )
end

function num_sword_frames()
    return #sword_frames
end
