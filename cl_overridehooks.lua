local function onRefresh()
    if !ahud.DisableModules.AddYellowIcon then
        hook.Remove( "InitPostEntity", "CreateVoiceVGUI" )
    end

    if !ahud.DisableModules.ChatIndicatorRemover then
        hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    end

    if !ahud.DisableModules.OwnerFPP then
        hook.Remove("HUDPaint", "FPP_HUDPaint")
    end
end

hook.Add("PreGamemodeLoaded", "RemoveYellowVoice", onRefresh)
onRefresh()