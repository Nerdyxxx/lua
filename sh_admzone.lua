local prefix = '!'
local poses = {
    Vector(-556, 774, 3200) -- один или несколько фулл рандом
	-- Vector(0, 0, 0)
}

local agroups = { 
    ['user'] = false,
	['superadmin'] = true
}

hook.Add('PlayerSay', 'Sit::Think::CMD', function(ply, str)
    if string.lower(str) == prefix..'adm' then
        if !agroups[ply:GetUserGroup()] then DarkRP.notify(ply, NOTIFY_ERROR, 2, 'Доступно только для администрации') return '' end
        ply:SetPos(poses[math.random(#poses)]) return ''
    end
end)