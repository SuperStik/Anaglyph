local width, height = ScrW(), ScrH()
local tex_left = GetRenderTargetEx("_rt_AnaglyphLeft", width, height, RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_SEPARATE, 258, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_BGR888)
local tex_Right = GetRenderTargetEx("_rt_AnaglyphRight", width, height, RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_SEPARATE, 258, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_BGR888)
local mat_left = CreateMaterial("pp/anaglyphleft", "UnlitGeneric", {
	["$fbtexture"] = "_rt_AnaglyphLeft",
	["$ignorez"] = "1"
})
local mat_right = CreateMaterial("pp/anaglyphleft", "UnlitGeneric", {
	["$fbtexture"] = "_rt_AnaglyphRight",
	["$ignorez"] = "1"
})
mat_left:SetTexture( "$fbtexture", tex_left )
mat_right:SetTexture( "$fbtexture", tex_right )
--[[---------------------------------------------------------
	Register the convars that will control this effect
-----------------------------------------------------------]]
local pp_anaglyph = CreateClientConVar( "pp_anaglyph", "0", false, false )
local pp_anaglyph_size = CreateClientConVar( "pp_anaglyph_size", "6", true, false, nil, -11.5, 11.5 )

--[[---------------------------------------------------------
	Can be called from engine or hooks using bloom.Draw
-----------------------------------------------------------]]
function RenderAnaglyph( ViewOrigin, ViewAngles )

	render.UpdateScreenEffectTexture()

	local Right = ViewAngles:Right() * pp_anaglyph_size:GetFloat()

	local view = {origin = ViewOrigin + Right, angles = ViewAngles}

	-- Left
	render.RenderView( view )

	-- Right
	view.origin = ViewOrigin - Right
	render.RenderView( view )

end

--[[---------------------------------------------------------
	The function to draw the bloom (called from the hook)
-----------------------------------------------------------]]
hook.Add( "RenderScene", "RenderAnaglyph", function( ViewOrigin, ViewAngles )

	if ( !pp_anaglyph:GetBool() ) then return end

	RenderAnaglyph( ViewOrigin, ViewAngles )

	-- Return true to override drawing the scene
	return true

end )

list.Set( "PostProcess", "Anaglyph", {

	icon = "gui/postprocess/stereoscopy.png",
	convar = "pp_anaglyph",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:AddControl( "Header", { Description = "#stereoscopy_pp.desc" } )
		CPanel:AddControl( "CheckBox", { Label = "#stereoscopy_pp.enable", Command = "pp_anaglyph" } )

		local params = { Options = {}, CVars = {}, MenuButton = "1", Folder = "stereoscopy" }
		params.Options[ "#preset.default" ] = { pp_anaglyph_size = "6" }
		params.CVars = table.GetKeys( params.Options[ "#preset.default" ] )
		CPanel:AddControl( "ComboBox", params )

		CPanel:AddControl( "Slider", { Label = "#stereoscopy_pp.size", Command = "pp_anaglyph_size", Type = "Float", Min = "0", Max = "10" } )

	end

} )
