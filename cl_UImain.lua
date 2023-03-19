function ahud.CachedCircle(x, y, radius, seg)
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 )
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    return cir
end

// Stencils
function ahud.StartStencil()
    render.ClearStencil()
    render.SetStencilEnable( true )
    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )

    render.SetStencilPassOperation( STENCIL_REPLACE )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )
    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilReferenceValue( 1 )
end

function ahud.ReplaceStencil(id)
    render.SetStencilCompareFunction( STENCIL_EQUAL )

    render.SetStencilPassOperation( STENCIL_REPLACE )
    render.SetStencilReferenceValue( id or 0 )
end

function ahud.EndStencil()
    render.SetStencilEnable( false )
end

function ahud.AddHoverTimer(pnl, ratio)
    pnl.perc = 0
    ratio = ratio or 1

    local oldPaint = pnl.Paint

    function pnl:Paint(w, h)
        local rft = FrameTime() * ratio

        if self:IsHovered() then
            self.perc = self.perc + rft

            if self.perc >= 1 then
                // I don't remember why I put 0.999, but I think it was related to a bug with some animations
                self.perc = 0.999
            end
        else
            self.perc = (self.perc or 0) - rft

            if self.perc < 0 then
                self.perc = 0
            end
        end

        self.renderTime = rft

        oldPaint(self, w, h)
    end
end

function ahud.ColorTo(clr1, clr2, ratio)
    return Color(
        Lerp(ratio, clr1.r, clr2.r),
        Lerp(ratio, clr1.g, clr2.g),
        Lerp(ratio, clr1.b, clr2.b),
        Lerp(ratio, clr1.a or 255, clr2.a or 255)
    )
end

local blur = Material("pp/blurscreen")
function ahud.Blur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()

    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end

// Popup
local stripes = Material("akulla/flux/stripes.png", "smooth noclamp")
local hue, sat, val = ColorToHSV(ColorAlpha(ahud.Colors.HUD_Background, 255))
val = 0.45

local red = HSVToColor(hue, sat, val)

function ahud.Popup(message, title, clr1, clr2)
    local c = CurTime()
    local redstripes = clr2 or red

    hook.Add("ahud_draw", "ahud.Popup",function(local_ply, w, h)
        local dif = CurTime() - c
        if dif > 5 then
            hook.Remove("HUDPaint", "ahud.Popup")
            return
        end

        local wStart = 0

        if dif > 4 then
            wStart = 1 - (5 - dif)
        elseif dif < 1 then
            wStart = 1 - dif
        end

        wStart = -w * math.ease.OutSine(wStart)

        surface.SetDrawColor(ahud.Colors.C40)
        surface.DrawRect(wStart, h * 0.1, w, h * 0.3)

        redstripes.a = math.abs(math.sin(CurTime() * 3)) * 20 + 5

        surface.SetMaterial(stripes)
        surface.SetDrawColor(redstripes)

        local slide = CurTime() * 2

        surface.DrawTexturedRectUV(wStart, h * 0.1, w, h * 0.3, slide, 0, 50 + slide, 2)

        surface.SetDrawColor(clr1 or ahud.Colors.HUD_Bar)
        surface.DrawRect(wStart, h * 0.1, w, 2)
        surface.DrawRect(wStart, h * 0.4, w, 2)

        local _, texth = draw.SimpleText(title, "ahud_60B", w / 2 + wStart, h * 0.15, color_white, 1, 1)
        texth = texth + select(2, draw.SimpleText(message, "ahud_40", w / 2 + wStart, h * 0.15 + texth, color_white, 1, 0))
    end)
end

function ahud.Popup2(message, title, time)
    local c = CurTime()

    surface.SetFont("ahud_17")
    local _, txtH = surface.GetTextSize(title)

    hook.Add("ahud_draw", "ahud.Popup", function(local_ply, w, h)
        local dif = CurTime() - c
        if dif > (time or 5) then
            hook.Remove("HUDPaint", "ahud.Popup")
            return
        end

        local alpha = 255
        local clr1 = ahud.Colors.C200_120
        local clr2 = color_white

        if dif > (time - 1) then
            alpha = 1 - math.ease.OutSine(1 - (time - dif))
        elseif dif < 1 then
            alpha = 1 - math.ease.OutSine(1 - dif)
        end

        if alpha < 1 then
            clr1 = ColorAlpha(ahud.Colors.C200_120, alpha * 120)
            clr2 = ColorAlpha(color_white, alpha * 255)
        end

        draw.DrawText(title, "ahud_17", w / 2, h * 0.25, clr1, 1)
        draw.DrawText(message, "ahud_25", w / 2, h * 0.25 + txtH, clr2, 1)
    end)
end

local p = FindMetaTable("Panel")
function p:ahud_AlphaHover(num)
    local clr = ahud.Colors.C160

    if num then
        clr = ColorAlpha(ahud.Colors.C230, num)
    end

    function self:OnCursorEntered()
        self:SetTextColor(ahud.Colors.C230)
    end

    function self:OnCursorExited()
        self:SetTextColor(clr)
    end

    self:SetTextColor(clr)
    self:SetMouseInputEnabled(true)
end

function ahud.drawText(txt, w, h, color)
    surface.SetTextColor(color)
    surface.SetTextPos(w, h)
    surface.DrawText(txt)
end

function ahud.drawCentered(txt, font, w, h, color)
    surface.SetFont(font)
    surface.SetTextColor(color)

    local txtw, txth = surface.GetTextSize(txt)
    surface.SetTextPos(w - txtw / 2, h - txth / 2)
    surface.DrawText(txt)

    return txtw
end

usermessage.Hook("AdminTell", function(msg)
    ahud.Popup(msg:ReadString(), DarkRP.getPhrase("listen_up"))
end)

hook.Add("PostGamemodeLoaded", "ahud_detourNotif", function()
    usermessage.Hook("AdminTell", function(msg)
        ahud.Popup(msg:ReadString(), DarkRP.getPhrase("listen_up"))
    end)
end)