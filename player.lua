--player code

local recovery_frames = 15

local player_states = {
    neutral = 0,
    attack1 = 1,
    attack2 = 2,
    recovery = 3,
    recovery2 = 4,
    recovery3 = 5,
}

local player = {
    actor = nil,
    state = player_states.neutral,
    frame_count = 0,
    state_actions = {},
}

local player_animations = {}
local player_lr_head_sprites = {1}
local player_lr_head_frames = {60}
local player_lr_feet_sprites = {17, 18}
local player_lr_feet_frames = {20,20}
local player_up_head_sprites = {3}
local player_up_head_frames = {60}
local player_dwn_head_sprites = {1,2}
local player_dwn_head_frames = {30,30}
local player_updwn_feet_sprites = {19,20}
local player_updwn_feet_frames = {20,20}
local player_still_feet_sprites = {17}
local player_still_feet_frames = {60}
local player_still_animation = {}

player.state_actions[player_states.neutral] = function()
    if (btnp(x_btn)) then
        player.state = player_states.attack1
        player.sword.frame = 1
        player.sword.direction = player.direction
    end
end

player.state_actions[player_states.attack1] = function()
    check_sword_collisions(player.sword, player.actor)
    player.sword.frame += 1
    if (player.sword.frame == num_sword_frames()) then
        player.frame_count = recovery_frames
        player.state = player_states.recovery
    end
end

player.state_actions[player_states.attack2] = function()
    check_sword_collisions(player.sword, player.actor)
    player.sword.frame -= 1
    if (player.sword.frame == 1) then
        player.state = player_states.recovery2
        player.frame_count = recovery_frames
    end
end

player.state_actions[player_states.recovery] = function()
    if (btnp(x_btn)) then
        player.state = player_states.attack2
    else
        player.frame_count -= 1
        if (player.frame_count == 0) then
            player.state = player_states.recovery3
            player.frame_count = recovery_frames
        end
    end
end

player.state_actions[player_states.recovery2] = function()
    player.frame_count -= 1
    if (player.frame_count == 0) then
        player.state = player_states.recovery3
        player.frame_count = recovery_frames
    end
end

player.state_actions[player_states.recovery3] = function()
    player.frame_count -= 1
    if (player.frame_count == 0) then
        player.state = player_states.neutral
    end
end

local function player_process_dir_input()
    local dx,dy = 0,0

    if btn(left_btn) then
        player.direction = directions.left 
        player.actor.animations = player_animations[directions.left]
        player.actor.flip_x = true
        dx += -1 dy += 0
    end
    if btn(right_btn) then
        player.direction = directions.right 
        player.actor.animations = player_animations[directions.right]
        player.actor.flip_x = false
        dx += 1 dy += 0
    end
    if btn(up_btn) then
        player.direction = directions.up 
        player.actor.animations = player_animations[directions.up]
        dx += 0 dy += -1
    end
    if btn(down_btn) then
        player.direction = directions.down 
        player.actor.animations = player_animations[directions.down]
        dx += 0 dy += 1
    end

    if (dx == 0 and dy == 0) then 
        player.actor.animations = { player_still_animation, player.actor.animations[2] }
    end

    player.actor.dx = dx
    player.actor.dy = dy
end

local function update_player(this)
    player_process_dir_input()
    player.state_actions[player.state]()
end

local function on_sword_collision(this)
    set_sticky_friction(10)
    player.actor.enabled = false;
end

local function draw_player_sword()
    if (player.state == player_states.neutral) then
        return
    end
    
    draw_sword(player.sword, player.actor)
end

function init_player()
    player_animations, player_still_animation = create_character_animation()

    player.actor = create_actor{
        animations = player_animations[directions.left], 
        x=37, y=61, 
        w=7, h=7, 
        speed=0.125, 
        parent = player,
        on_update = update_player,
        on_cant_move = cant_move_player,
        palate = {[7]=2}, -- swap white sprite for burgandy
        on_sword_collision = on_sword_collision,
        post_draw = draw_player_sword,
    }
    player.direction = directions.up
    player.sword = create_sword()
end

function get_player_pos()
    return player.actor.x, player.actor.y
end

function cant_move_player(actor)
	-- stub
end
