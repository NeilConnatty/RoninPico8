
local recovery_frames = 30
local attack_delay_frames = 5

local enemy_states = {
    neutral = 0,
    follow_player_x = 1,
    follow_player_y = 2,
    attack1 = 3,
    recovery1 = 4,
}

local enemy_animations = {}
local enemy_still_animations = {}

local enemies = {}

local function on_sword_collision(enemy)
    set_sticky_friction(10)
    enemy.actor.enabled = false
end

local function on_update(enemy)
    enemy.state_actions[enemy.state](enemy)
end

local function on_cant_move(enemy)
    enemy.actor.dx *= -1
    enemy.actor.dy *= -1
end

local function can_see_player_x(enemy, px, py)
    local dist_x = enemy.actor.x - px
    if (-1 < dist_x and dist_x < 1) then
        if (enemy.actor.y > py) then
            for y = py, enemy.actor.y do
                if is_tile(sprite_flags.wall, px, y) then return false end 
            end
            return true
        else --(enemy.actor.y < py)
            for y = enemy.actor.y, py do
                if is_tile(sprite_flags.wall, px, y) then return false end 
            end
            return true
        end
    end
    return false
end

local function can_see_player_y(enemy, px, py)
    local dist_y = enemy.actor.y - py
    if (-1 < dist_y and dist_y < 1) then
        if (enemy.actor.x > px) then
            for x = px, enemy.actor.x do
                if is_tile(sprite_flags.wall, x, py) then return false end 
            end
            return true
        else -- (enemy.actor.x < px)
            for x = enemy.actor.x, px do 
                if is_tile(sprite_flags.wall, px, y) then return false end 
            end
            return true
        end
    end
    return false
end

local function update_direction_neutral(enemy)
    if (enemy.actor.dx < 0) then 
        enemy.direction = directions.left 
        enemy.actor.animations = enemy_animations[directions.left]
        enemy.actor.flip_x = true
    elseif (enemy.actor.dx > 0) then 
        enemy.direction = directions.right
        enemy.actor.animations = enemy_animations[directions.right]
        enemy.actor.flip_x = false
    elseif (enemy.actor.dy < 0) then 
        enemy.direction = directions.up 
        enemy.actor.animations = enemy_animations[directions.up]
    elseif (enemy.actor.dy > 0) then 
        enemy.direction = directions.down 
        enemy.actor.animations = enemy_animations[directions.down]
    elseif (enemy.actor.dx == 0 and enemy.actor.dy == 0) then 
        enemy.actor.animations = { enemy_still_animations, enemy.actor.animations[2] }
    end
end

local function neutral_update(enemy)
    local px,py = get_player_pos()
    if (can_see_player_x(enemy, px, py)) then
        enemy.state = enemy_states.follow_player_x
    elseif (can_see_player_y(enemy, px, py)) then
        enemy.state = enemy_states.follow_player_y
    else
        update_direction_neutral(enemy)
    end
end

local function update_direction_follow(enemy)
    local px, py = get_player_pos()
    if (enemy.state == enemy_states.follow_player_x) then
        if (enemy.actor.y > py) then 
            enemy.direction = directions.up 
        elseif (enemy.actor.y < py) then 
            enemy.direction = directions.down 
        end
    elseif (enemy.state == enemy_states.follow_player_y) then
        if (enemy.actor.x > px) then 
            enemy.direction = directions.left
            enemy.actor.flip_x = true
        elseif (enemy.actor.x < px) then 
            enemy.direction = direction.right 
            enemy.actor.flip_x = false
        end 
    end
end

local function follow_player_update(enemy)
    enemy.actor.dx = 0; enemy.actor.dy = 0
    local px, py = get_player_pos()
    local dist_x = enemy.actor.x - px
    local dist_y = enemy.actor.y - py

    if (-2 < dist_x and dist_x < 2 and -2 < dist_y and dist_y < 2) then
        enemy.sword.direction = enemy.direction
        enemy.sword.frame = 1
        enemy.state = enemy_states.attack1
        enemy.frame_count = attack_delay_frames
        return
    end

    if (enemy.state == enemy_states.follow_player_x) then
        if      (dist_x < -0.125) then enemy.actor.dx = 1
        elseif  (dist_x > 0.125) then enemy.actor.dx = -1 end
    else
        if      (dist_y < -0.125) then enemy.actor.dy = 1
        elseif  (dist_y > 0.125) then enemy.actor.dy = -1 end
    end

    update_direction_neutral(enemy) -- update the direction for animation
    update_direction_follow(enemy) -- override the direction for attacking
end

local function attack_update(enemy)
    if (enemy.frame_count > 0) then
        enemy.frame_count -= 1
        return
    end

    check_sword_collisions(enemy.sword, enemy.actor)
    enemy.sword.frame += 1
    if (enemy.sword.frame == num_sword_frames()) then
        enemy.frame_count = recovery_frames
        enemy.state = enemy_states.recovery1
    end
end

local function recovery_update(enemy)
    if (enemy.frame_count > 0) then
        enemy.frame_count -= 1
        return
    end
    
    local px, py = get_player_pos()
    local dist_x = enemy.actor.x - px
    local dist_y = enemy.actor.y - py
    if (-2 < dist_x and dist_x < 2 and -2 < dist_y and dist_y < 2) then
        enemy.sword.direction = enemy.direction
        enemy.sword.frame = 1
        enemy.state = enemy_states.attack1
    else
        enemy.state = enemy_states.neutral
    end
end

local function post_draw(enemy)
    if (enemy.state == enemy_states.attack1 or enemy.state == enemy_states.recovery1) then
        draw_sword(enemy.sword, enemy.actor)
    end
end

function create_enemy(x, y)
    local new_enemy = {
        state = enemy_states.neutral,
        state_actions = {
            [enemy_states.neutral] = neutral_update,
            [enemy_states.follow_player_x] = follow_player_update,
            [enemy_states.follow_player_y] = follow_player_update,
            [enemy_states.attack1] = attack_update,
            [enemy_states.recovery1] = recovery_update,
        },
        sword = create_sword(),
        frame_count = 0,
        direction = directions.right
    }
    new_enemy.actor = create_actor{
        x = x, y = y,
        speed = 1/16,
        animations = enemy_animations[directions.left],
        parent = new_enemy,
        on_update = on_update,
        on_sword_collision = on_sword_collision,
        on_cant_move = on_cant_move,
        post_draw = post_draw
    }
    new_enemy.actor.dx = 1
    add(enemies, new_enemy)
end

function init_enemy_data()
    enemy_animations, enemy_still_animations = create_character_animation()
end
