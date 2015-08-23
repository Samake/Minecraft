--[[
	Name: Minecraft
	Filename: ShaderManagerC.lua
	Authors: Sam@ke
--]]


ShaderManagerC = {}

function ShaderManagerC:constructor(parent)
	mainOutput("ShaderManagerC was loaded.")
	
	self.mainClass = parent
	self.toggleShadersKey = "J"
	self.shadersEnabled = "true"
	
	self.m_toggleShaders = bind(self.toggleShaders, self)
	bindKey(self.toggleShadersKey, "down", self.m_toggleShaders)
	
	self:init()

end


function ShaderManagerC:toggleShaders()
	if (self.shadersEnabled == "true") then
		self:init()
		self.shadersEnabled = "false"
	elseif (self.shadersEnabled == "false") then
		self:clear()
		self.shadersEnabled = "true"
	end
	
	mainOutput("CLIENT // Shaders enabled: " .. self.shadersEnabled)
end



function ShaderManagerC:init()
	if (not self.diffuseLightShader) then
		self.diffuseLightShader = new(ShaderDiffuseLightC, self)
	end
end


function ShaderManagerC:update()
	if (self.diffuseLightShader) then
		self.diffuseLightShader:update()
	end
end


function ShaderManagerC:clear()
	if (self.diffuseLightShader) then
		delete(self.diffuseLightShader)
		self.diffuseLightShader = nil
	end
end


function ShaderManagerC:destructor()
	unbindKey(self.toggleShadersKey, "down", self.m_toggleShaders)

	self:clear()
	
	mainOutput("ShaderManagerC was deleted.")
end