local function drawMiddleOutlined(txt, font, offsetH, color, genOutline)
    surface.SetFont(font)
    local txtw, txth = surface.GetTextSize(txt)

    if genOutline then
        surface.SetTextColor(color_black)
        for i = -1, 1, 2 do
            for j = -1, 1, 2 do
                surface.SetTextPos(-txtw / 2 + i, offsetH + j)
                surface.DrawText(txt)
            end
        end
    end

    surface.SetTextColor(color)
    surface.SetTextPos(-txtw / 2, offsetH)
    surface.DrawText(txt)

    return txth
end

surface.CreateFont ("ahud_top", {
    size = 30 * (ahud.overheadScale or 1),
    font = "Roboto"
})

local offset = Vector( 0, 0, 75 )
local offsetHead = Vector(0, 0, 15)
local angHead = Angle( 0, 0, 90 )
local ura_clr = ahud.Colors.HUD_Bar

local plyLoaded = {}

local function drawPly(ply)
    local l = LocalPlayer()

    if !IsValid(ply) or !ply:Alive() or !IsValid(ply) then return end

    if !ahud.DisableModules.Overhead and ( l:GetPos():DistToSqr( ply:GetPos() ) < 300 * 300 ) then
        local ang = l:EyeAngles()
        local pos = ply:GetPos() + offset
        local targethead = ply:LookupBone("ValveBiped.Bip01_Head1")
        if isnumber(targethead) then
            local targetheadpos = ply:GetBonePosition(targethead)
            pos = targetheadpos + offsetHead
        end

        if l:InVehicle() then
            ang = l:GetVehicle():LocalToWorldAngles( LocalPlayer():EyeAngles() )
        end

        ang:RotateAroundAxis( ang:Forward(), 90 )
        ang:RotateAroundAxis( ang:Right(), 90 )

        angHead.y = ang.y

        cam.Start3D2D( pos, angHead, 0.05 )
            local offsetH = 0

            if DarkRP then
                offsetH = drawMiddleOutlined(ply:GetName(), "ahud_top", offsetH, ply:IsSpeaking() and ura_clr or color_white, true)
                offsetH = drawMiddleOutlined(team.GetName(ply:Team()), "ahud_top", offsetH, team.GetColor(ply:Team()), true) + offsetH
                if ply:isWanted() then
                    drawMiddleOutlined(DarkRP.getPhrase("Wanted_text"), "ahud_top", offsetH, color_white)
                elseif ply:getDarkRPVar("AFK") then
                    drawMiddleOutlined("AFK", "ahud_top", offsetH, color_white)
                end
            else
                drawMiddleOutlined(ply:GetName(), "ahud_top", offsetH, ply:IsSpeaking() and ura_clr or color_white, true)
            end

        cam.End3D2D()
    end
end


hook.Add("PostPlayerDraw", "ahud_DrawName", function(ply)
    table.insert(plyLoaded, ply)
end)

hook.Add("PostDrawTranslucentRenderables", "ahud_DrawName", function()
    for k, v in ipairs(plyLoaded) do
        drawPly(v)
    end
    plyLoaded = {}
end)

hook.Add("HUDDrawDoorData", "ahud_doors", function() return true end)