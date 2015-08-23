--[[
	Name: Minecraft
	Filename: ShaderDiffuseLightC.lua
	Authors: Sam@ke
--]]


ShaderDiffuseLightC = {}

function ShaderDiffuseLightC:constructor(parent)
	mainOutput("ShaderDiffuseLightC was loaded.")
	
	self.mainClass = parent
	self.effectRange = 256
	
	self.excludingTextures = 	{	"waterclear256",
									"*smoke*",
									"*particle*",
									"*cloud*",
									"*splash*",
									"*corona*",
									"*sky*",
									"*radar*",
									"*wgush1*",
									"*debris*",
									"*wjet4*",
									"*gun*",
									"*wake*",
									"*effect*",
									"*fire*",
									"muzzle_texture*",
									"*font*",
									"*icon*",
									"shad_exp*",
									"*headlight*", 
									"*corona*",
									"sfnitewindow_alfa", 
									"sfnitewindows", 
									"monlith_win_tex", 
									"sfxref_lite2c",
									"dt_scyscrap_door2", 
									"white", 
									"casinolights*",
									"cj_frame_glass", 
									"custom_roadsign_text", 
									"dt_twinklylites",
									"vgsn_nl_strip", 
									"unnamed", 
									"white64", 
									"lasjmslumwin1",
									"pierwin05_law", 
									"nitwin01_la", 
									"sl_dtwinlights1", 
									"fist",
									"sphere",
									"*spark*",
									"glassmall",
									"*debris*",
									"wgush1",
									"wjet2",
									"wjet4",
									"beastie",
									"bubbles*",
									"pointlight",
									"unnamed",
									"txgrass*", 
									"item*",
									"undefined*",
									"coin*",
									"turbo*",
									"lava*",
									"ampelLight*",
									"*shad*",
									"cj_w_grad",
									"*water*",
									"font*"}

	self.diffuseLightShader = dxCreateShader("res/shaders/diffuseLight.fx", 0, self.effectRange, true, "object")
	
	if (not self.diffuseLightShader) then
		mainOutput("CLIENT // Loading diffuse light shader failed. Please use ´/debugscript 3´ for further details")
		
		self:removeShaders()
	else
		self.diffuseLightShader:applyToWorldTexture("*")
		
		for _, texture in ipairs(self.excludingTextures) do
			self.diffuseLightShader:removeFromWorldTexture(texture)
		end	
		
	end
end


function ShaderDiffuseLightC:update()
	if (self.diffuseLightShader) then
	
	end
end


function ShaderDiffuseLightC:removeShaders()
	
	if (self.diffuseLightShader) then
		self.diffuseLightShader:destroy()
		self.diffuseLightShader = nil
	end
end


function ShaderDiffuseLightC:destructor()

	self:removeShaders()
	
	mainOutput("ShaderDiffuseLightC was deleted.")
end