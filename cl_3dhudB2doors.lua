// darkrp code
local changeDoorAccess = false

local function updatePrivs()
    CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_ChangeDoorSettings", function(b, _)
        changeDoorAccess = b
    end)
end


ahud.vehicleClassName = ahud.vehicleClassName or {}

hook.Add("InitPostEntity", "ahud_loadvehicles", function()
    updatePrivs()
    timer.Create("Door changeDoorAccess checker", 2, 0, updatePrivs)

    for k, v in pairs(list.Get("Vehicles")) do
        ahud.vehicleClassName[k] = v.Name
    end
end)

//
local dst = ahud.maxDistDraw or (200 * 200)
local minDst = ahud.minDistDraw or (150 * 150)
hook.Add("ahud_draw", "ahud_vehicledoor", function(local_ply, w, h, ent, c1, c2)
    if !DarkRP or !IsValid(ent) or !ent:IsVehicle() or local_ply:InVehicle() then return end
    if ent:GetPos():DistToSqr(local_ply:GetPos()) > dst then return end

    local blocked = ent:getKeysNonOwnable()
    local doorTeams = ent:getKeysDoorTeams()
    local doorGroup = ent:getKeysDoorGroup()
    local playerOwned = ent:isKeysOwned() or select(2, next(ent:getKeysCoOwners() or {})) ~= nil

    local doorInfo = {}

    local title = ent:getKeysTitle()
    if title then table.insert(doorInfo, title) end

    if playerOwned then
        if ent:isKeysOwned() then table.insert(doorInfo, ent:getDoorOwner():Nick()) end
        for k in pairs(ent:getKeysCoOwners() or {}) do
            local ent = Player(k)
            if !IsValid(ent) then continue end
            table.insert(doorInfo, ent:Nick())
        end

        local allowedCoOwn = ent:getKeysAllowedToOwn()
        if allowedCoOwn and !fn.Null(allowedCoOwn) then
            table.insert(doorInfo, DarkRP.getPhrase("keys_other_allowed"))

            for k in pairs(allowedCoOwn) do
                local ent = Player(k)
                if !IsValid(ent) then continue end
                table.insert(doorInfo, ent:Nick())
            end
        end
    elseif doorGroup then
        table.insert(doorInfo, doorGroup)
    elseif doorTeams then
        for k, v in pairs(doorTeams) do
            if !v or !RPExtraTeams[k] then continue end

            table.insert(doorInfo, RPExtraTeams[k].name)
        end
    elseif blocked and changeDoorAccess then
        table.insert(doorInfo, DarkRP.getPhrase("keys_allow_ownership"))
    elseif !blocked then
        table.insert(doorInfo, ahud.L("KeysBuy") .. " " .. DarkRP.formatMoney(GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30))
    end

    // Format text

    local text = table.concat(doorInfo, "\n")
    local text2 = ahud.vehicleClassName[ent:GetVehicleClass()] or "Unknown"

    surface.SetFont("ahud_25")
    local tx, ty = surface.GetTextSize(text)

    surface.SetFont("ahud_17")
    local t2x, t2y = surface.GetTextSize(text2)

    local middlew = w / 2
    local middleh = h / 2

    tx = (tx < t2x and t2x or tx) + 20
    ty = ty + 20
    ty = ty + t2y

    draw.RoundedBox(0, middlew - tx / 2, middleh, tx, ty, c1)
    draw.RoundedBox(0, middlew - tx / 2, middleh + ty - 5, tx, 5, c2)

    draw.SimpleText(text, "ahud_25", middlew, middleh + ty / 2, textcolor, 1, 4)
    draw.SimpleText(text2, "ahud_17", middlew, middleh + ty / 2, ahud.Colors.C200_120, 1, 3)
end)

hook.Add("PostDrawTranslucentRenderables", "ahud_doors", function()
    if ahud.inCar or !DarkRP then return end

    local ply = LocalPlayer()
    local e = ply:GetEyeTrace().Entity

    if !IsValid(e) or !e:isKeysOwnable() or e:IsVehicle() then return end
    // Calculate 3D2D pos
    local c = e:OBBCenter()
    local worldPos = e:LocalToWorld(c)
    local plyPos = ply:GetPos()
    local pdst = worldPos:DistToSqr(plyPos)

    if (pdst > dst) then return end

    local size = e:OBBMaxs() - e:OBBMins()
    local pts
    local sideSize

    if size.z < size.x and size.z < size.y then
        pts = e:GetUp() * size.z
        sideSize = size.y
    elseif size.y < size.x then
        pts = e:GetRight() * size.y
        sideSize = size.x
    else
        pts = e:GetForward() * size.x
        sideSize = size.y
    end


    if plyPos:DistToSqr(pts + worldPos) > plyPos:DistToSqr(-pts + worldPos) then
        pts = -pts
    end

    local finalPos = pts + worldPos


    local tr = util.TraceLine({
        start = finalPos,
        endpos = worldPos,
    })
    finalPos = tr.HitPos + pts:GetNormalized()

    if tr.Entity != e then return end

    local ang = tr.Normal:Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)


    local stateID = 0
    local shouldRefresh = false

    if e:getKeysNonOwnable() then
        // Blocked
        stateID = 1
    elseif (e:isKeysOwned() or select(2, next(e:getKeysCoOwners() or {})) ~= nil) then
        stateID = 2
        local coOwners = e:getKeysCoOwners() or {}
        local coOwners2 = e:getKeysAllowedToOwn() or {}
        local info = e.ahud_doorCheck and e.ahud_doorCheck.info or nil

        if !info then
            shouldRefresh = true
        elseif table.Count(coOwners) == table.Count(info[1]) and table.Count(coOwners2) == table.Count(info[2]) then
            for k, v in pairs(info[1]) do
                if !coOwners[k] or coOwners[k] != v then
                    shouldRefresh = true
                    break
                end
            end

            if !shouldRefresh then
                for k, v in pairs(info[2]) do
                    if !coOwners2[k] or coOwners2[k] != v then
                        shouldRefresh = true
                        break
                    end
                end
            end
        else
            shouldRefresh = true
        end
    elseif e:getKeysDoorGroup() then
        stateID = 3
        shouldRefresh = !e.ahud_doorCheck or e:getKeysDoorGroup() != e.ahud_doorCheck.info
    elseif e:getKeysDoorTeams() then
        stateID = 4
        shouldRefresh = !e.ahud_doorCheck or e:getKeysDoorTeams() != e.ahud_doorCheck.info
    end


    local title = e:getKeysTitle()

    if !e.ahud_doormarkup or shouldRefresh or (e.ahud_doorCheck and (e.ahud_doorCheck.stateid != stateID or e.ahud_doorCheck.lastitle != title)) then
        local str = "<font=ahud_40>"

        if title and title != "" then
            str = str .. title .. "\n"
        end

        if stateID == 2 or stateID == 3 or stateID == 4 then
            str = str .. "<color=" .. markup.Color( ahud.Colors.HUD_Bar ) .. ">" .. DarkRP.getPhrase("keys_owned_by") .. "\n</font><font=ahud_60>"
        end

        local info

        if stateID == 1 then
            if changeDoorAccess then
                str = str .. "<color=" .. markup.Color( ahud.Colors.HUD_Bad ) .. ">" .. DarkRP.getPhrase("keys_allow_ownership")
            end
        elseif stateID == 2 then
            local owners = {}
            local coOwners = e:getKeysCoOwners() or {}
            local coOwners2 = e:getKeysAllowedToOwn() or {}

            info = {
                coOwners, coOwners2
            }

            if e:isKeysOwned() then
                table.insert(owners, e:getDoorOwner():Nick())
            end

            for k in pairs(coOwners) do
                local ent = Player(k)
                if !IsValid(ent) or !ent:IsPlayer() then continue end
                table.insert(owners, ent:Nick())
            end

            str = str .. "</color>" .. table.concat(owners, ", ")

            owners = {}

            local allowedCoOwn = coOwners2
            if allowedCoOwn and !fn.Null(allowedCoOwn) then
                str = str .. "<color=" .. markup.Color( ahud.Colors.HUD_Bar ) .. ">"
                for k in pairs(allowedCoOwn) do
                    local ent = Player(k)
                    if !IsValid(ent) or !ent:IsPlayer() then continue end
                    table.insert(owners, ent:Nick())
                end
            end

            if !table.IsEmpty(owners) then
                str = str .. "\n\n" .. "<font=ahud_40>" .. DarkRP.getPhrase("keys_other_allowed") .. "\n" .. "</color></font><font=ahud_60>" .. table.concat(owners, ", ")
            end
        elseif stateID == 3 then
            local keyDoor = e:getKeysDoorGroup()
            info = keyDoor
            str = str .. "</color>" .. keyDoor
        elseif stateID == 4 then
            local nameTbl = {}
            local keyDoor = e:getKeysDoorTeams()
            info = keyDoor

            for k, v in pairs(keyDoor) do
                if !v or !RPExtraTeams[k] then continue end
                table.insert(nameTbl, RPExtraTeams[k].name)
            end

            str = str .. "<color=" ..  markup.Color( color_white ) .. ">" .. table.concat(nameTbl, ", ")
        else
            str = str .. ahud.L("KeysBuy") .. "\n<color=" .. markup.Color( ahud.Colors.HUD_Good ) .. "><font=ahud_60>" .. DarkRP.formatMoney(GAMEMODE.Config.doorcost != 0 and GAMEMODE.Config.doorcost or 30) .. " (F2)</color>"

            if changeDoorAccess then
                str = str .. DarkRP.getPhrase("keys_disallow_ownership")
            end
        end

        e.ahud_doormarkup = markup.Parse( str, sideSize * 10 )
        e.ahud_doorCheck = {
            stateid = stateID,
            lasttitle = title,
            info = info,
        }
    end

    if e.ahud_doormarkup then
        cam.Start3D2D(finalPos, ang, 0.08)
            local a = 1 - ((pdst - minDst) / (dst - minDst))
            a = a > 1 and 255 or a * 255
            e.ahud_doormarkup:Draw(-sideSize * 5, 0, 0, 1, a, 1)
        cam.End3D2D()
    end
end)


hook.Add("HUDDrawDoorData", "ahud_doors", function() return true end)