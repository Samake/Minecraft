--[[
	Name: Minecraft
	Filename: ModelHandlerC.lua
	Authors: Sam@ke
--]]


ModelHandlerC = {}

function ModelHandlerC:constructor(parent)
	mainOutput("ModelHandlerC was loaded.")
	
	self.mainClass = parent
	self.lodDistance = 300
	
	self.texturePack = engineLoadTXD("res/models/minecraft.txd")
	self.blockCol = engineLoadCOL("res/models/blockCol.col")
	self.doorCol = engineLoadCOL("res/models/doorCol.col")
	
	-- // terrain // --
	self.terrainID = 15049
	self.terrainModel = engineLoadDFF("res/models/terrainPlane.dff")
	self.terrainCol = engineLoadCOL("res/models/terrainCol.col")
		
	engineImportTXD(self.texturePack, self.terrainID)
	engineReplaceModel(self.terrainModel, self.terrainID)
	engineReplaceCOL(self.terrainCol, self.terrainID)
	
	-- // blocks // --
	-- ids 1851 - 1882
	
	self.blockStoneID = 1851
	self.blockStoneModel = engineLoadDFF("res/models/stoneBlock.dff")
		
	engineImportTXD(self.texturePack, self.blockStoneID)
	engineReplaceModel(self.blockStoneModel, self.blockStoneID)
	engineReplaceCOL(self.blockCol, self.blockStoneID)
	
	self.blockDirtID = 1852
	self.blockDirtModel = engineLoadDFF("res/models/dirtBlock.dff")
		
	engineImportTXD(self.texturePack, self.blockDirtID)
	engineReplaceModel(self.blockDirtModel, self.blockDirtID)
	engineReplaceCOL(self.blockCol, self.blockDirtID)
	
	
	self.blockGrassID = 1853
	self.blockGrassModel = engineLoadDFF("res/models/grassBlock.dff")
		
	engineImportTXD(self.texturePack, self.blockGrassID)
	engineReplaceModel(self.blockGrassModel, self.blockGrassID)
	engineReplaceCOL(self.blockCol, self.blockGrassID)
	
	self.grassPlantID = 1854
	self.grassPlantModel = engineLoadDFF("res/models/grassPlant.dff")
		
	engineImportTXD(self.texturePack, self.grassPlantID)
	engineReplaceModel(self.grassPlantModel, self.grassPlantID)
	
	self.blockSandID = 1855
	self.blockSandModel = engineLoadDFF("res/models/sandBlock.dff")
		
	engineImportTXD(self.texturePack, self.blockSandID)
	engineReplaceModel(self.blockSandModel, self.blockSandID)
	engineReplaceCOL(self.blockCol, self.blockSandID)
	
	self.blockGlassWhiteID = 1856
	self.blockGlassWhiteModel = engineLoadDFF("res/models/glassWhiteBlock.dff", self.blockGlassWhiteID)
		
	engineImportTXD(self.texturePack, self.blockGlassWhiteID)
	engineReplaceModel(self.blockGlassWhiteModel, self.blockGlassWhiteID)
	engineReplaceCOL(self.blockCol, self.blockGlassWhiteID)
	
	self.sapplingOakID = 1857
	self.sapplingOakModel = engineLoadDFF("res/models/sapplingOak.dff")
		
	engineImportTXD(self.texturePack, self.sapplingOakID)
	engineReplaceModel(self.sapplingOakModel, self.sapplingOakID)
	
	self.blockWoodOAKID = 1858
	self.blockWoodOAKModel = engineLoadDFF("res/models/woodBlockOAK.dff")
		
	engineImportTXD(self.texturePack, self.blockWoodOAKID)
	engineReplaceModel(self.blockWoodOAKModel, self.blockWoodOAKID)
	engineReplaceCOL(self.blockCol, self.blockWoodOAKID)
	
	self.blockLeavesOAKID = 1859
	self.blockLeavesOAKModel = engineLoadDFF("res/models/leavesBlockOAK.dff")
		
	engineImportTXD(self.texturePack, self.blockLeavesOAKID)
	engineReplaceModel(self.blockLeavesOAKModel, self.blockLeavesOAKID)
	engineReplaceCOL(self.blockCol, self.blockLeavesOAKID)
	
	-- // doors // --
	-- ids 1830 - 1838
	
	self.doorWoodID = 1830
	self.doorWoodModel = engineLoadDFF("res/models/doorWood.dff", self.doorWoodID)
		
	engineImportTXD(self.texturePack, self.doorWoodID)
	engineReplaceModel(self.doorWoodModel, self.doorWoodID)
	engineReplaceCOL(self.doorCol, self.doorWoodID)

	self:setLodDistance()
end


function ModelHandlerC:setLodDistance()
	for index, object in ipairs(getElementsByType("object")) do
		if isElement(object) and (object:isLowLOD()) then
			local modelID = object:getModel()
			engineSetModelLODDistance(modelID, self.lodDistance)
		end
		
		object:setDoubleSided(true)
	end
end


function ModelHandlerC:destructor()
	
	mainOutput("ModelHandlerC was deleted.")
end