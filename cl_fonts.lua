local ratio_h = ScrH() / 1080
local ratio_w = ScrW() / 1920
local ratio = ratio_h < ratio_w and ratio_h or ratio_w

function ahud.GetSize(n)
    return n * ratio * (ahud.scaleSize or 1)
end

function createfonts()
    //
    surface.CreateFont("ahud_25", {
        font = "Averta",
        size = ahud.GetSize(25),
        antialias = true,
    })

    surface.CreateFont("ahud_17_500", {
        font = "Averta-Semibold",
        size = ahud.GetSize(17),
        antialias = true,
        weight = 500,
    })

    surface.CreateFont("ahud_40", {
        font = "Averta",
        size = ahud.GetSize(40),
        antialias = true,
    })

    surface.CreateFont("ahud_120", {
        font = "Averta-Semibold",
        size = ahud.GetSize(120),
        antialias = true,
    })

    surface.CreateFont("ahud_60", {
        font = "Averta-Semibold",
        size = ahud.GetSize(60),
        antialias = true,
    })

    surface.CreateFont("ahud_60B", {
        font = "Averta-ExtraBold",
        size = ahud.GetSize(60),
        antialias = true,
    })

    surface.CreateFont("ahud_17", {
        font = "Averta-Semibold",
        size = ahud.GetSize(17),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon40", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(40),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon30", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(30),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon128", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(128),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon64", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(64),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon22", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(22),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon16", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(16),
        antialias = true,
    })

    surface.CreateFont("ahud_Icon14", {
        font = "Akulla_SVG1",
        size = ahud.GetSize(14),
        antialias = true,
    })

    surface.CreateFont("ahud_Oops", {
        font = "Volaroid Script",
        size = ahud.GetSize(250),
        antialias = true,
    })
end

createfonts()

hook.Add("OnScreenSizeChanged", "ahudRefreshFont", function()
    ratio_h = ScrH() / 1080
    ratio_w = ScrW() / 1920
    local new_ratio = ratio_h < ratio_w and ratio_h or ratio_w
    if new_ratio == ratio then return end

    ratio = new_ratio
    createfonts()
    hook.Run("ahudPostScreenSizeChanged")
end)