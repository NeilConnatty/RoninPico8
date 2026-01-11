
local lr_head_sprites = {1}
local lr_head_frames = {60}
local lr_feet_sprites = {17, 18}
local lr_feet_frames = {20,20}
local up_head_sprites = {3}
local up_head_frames = {60}
local dwn_head_sprites = {1,2}
local dwn_head_frames = {30,30}
local updwn_feet_sprites = {19,20}
local updwn_feet_frames = {20,20}
local still_feet_sprites = {17}
local still_feet_frames = {60}

function create_animation(sprites, frame_times)
    assert(#sprites == #frame_times, "array of sprites should equal size of array of frame_times")
    local new_animation = {
        sprites = sprites,
        frame_times = frame_times,
        curr_sprite = 1,
        curr_frame_time = 0
    }
    return new_animation
end

function update_animation(animation)
    if (animation.curr_frame_time == 0) then
        if (animation.curr_sprite == #animation.sprites) then 
            animation.curr_sprite = 1
        else
            animation.curr_sprite += 1
        end

        animation.curr_frame_time = animation.frame_times[animation.curr_sprite]
        return
    end

    animation.curr_frame_time -= 1
end

function get_current_sprite(animation)
    return animation.sprites[animation.curr_sprite]
end

function create_character_animation()
    local new_animations = {}
    new_animations[directions.up] = {
        create_animation(updwn_feet_sprites, updwn_feet_frames),
        create_animation(up_head_sprites, up_head_frames)
    }
    new_animations[directions.down] = {
        create_animation(updwn_feet_sprites, updwn_feet_frames),
        create_animation(dwn_head_sprites, dwn_head_frames)
    }
    new_animations[directions.left] = {
        create_animation(lr_feet_sprites, lr_feet_frames),
        create_animation(lr_head_sprites, lr_head_frames)
    }
    new_animations[directions.right] = {
        create_animation(lr_feet_sprites, lr_feet_frames),
        create_animation(lr_head_sprites, lr_head_frames)
    }
    local still_animation = create_animation(still_feet_sprites, still_feet_frames)

    return new_animations, still_animation
end
