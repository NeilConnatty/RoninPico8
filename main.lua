
local sticky_friction = {
    frames = 0
}

function set_sticky_friction(frames)
    sticky_friction.frames = frames
end

function _init()
    init_swords()
    init_enemy_data()
    init_player()
    init_map()
end

function _update60()
    if (sticky_friction.frames > 0) then
        sticky_friction.frames -= 1
        return
    end
    
    update_map()
    update_actors()

    move_actors()
end

function _draw()
    if (sticky_friction.frames > 0) then 
        return 
    end

	cls()

    draw_background()
    draw_actors()
    draw_foreground()
end