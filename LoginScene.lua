
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                1     2  3  4  5    6      7                                                  8                                                       9          10           11         12        13				14
--modelData: { sceneID, x, y, z, o, scale, alpha, [{ enabled[,omni,dirX,dirY,dirZ,ambIntensity[,ambR,ambG,ambB[,dirIntensity[,dirR,dirG,dirB]]]] }], sequence, widthSquish, heightSquish, path [,referenceID] [,cameraModel] }
--[[ DOCUMENTATION:
	sceneID:			number	- on which scene it's supposed to show up
	x:					number	- moves the model left and right  \
	y:					number	- moves the model up and down	   |	if the model doesn't show up at all try moving it around sometimes it will show up | blue white box: wrong path | no texture: texture is set through dbc, needs to be hardcoded | green texture: no texture
	z:					number	- moves the model back and forth  /
	o:					number	- the orientation in which direction the model will face | number in radians | math.pi = 180° | math.pi * 2 = 360° | math.pi / 2 = 90°
	scale:				number	- used to scale the model | 1 = normal size | does not scale particles of flames for example on no camera models, use width/heightSquish for that
	alpha:				number  - opacity of the model | 1 = 100% , 0 = 0%
	light:				table	- table containing light data (look in light documentation for further explanation) | is optional
	sequence:			number	- the animation that should be played after the model is loaded
	widthSquish:		number	- squishes the model on the X axis | 1 = normal
	heightSquish:		number	- squishes the model on the Y axis | 1 = normal
	path:				String  - the path to the model ends with .mdx
	referenceID:		number  - mainly used for making changes while the scene is playing | example:
	
	local m = GetModel(1)	<- GetModel(referenceID) the [1] to use the first model with this referenceID without it it would be a table with all models inside
	if m then
		m = m[1]
		local x,y,z = m:GetPosition()
		m:SetPosition(x-0.1,y,z)				<- move the model -0.1 from it's current position on the x-axis
	end
	
	cameraModel:		String	- if a path to a model is set here, it will be used as the camera
]]
--[[ LIGHT:
	enabled:			number	- appears to be 1 for lit and 0 for unlit
    omni:				number	- ?? (default of 0)
    dirX, dirY, dirZ:	numbers	- vector from the origin to where the light source should face
    ambIntensity:		number	- intensity of the ambient component of the light source
    ambR, ambG, ambB:	numbers	- color of the ambient component of the light source
    dirIntensity:		number	- intensity of the direct component of the light source
    dirR, dirG, dirB:	numbers	- color of the direct component of the light source 
]]
--[[ METHODS:
	GetModelData(referenceID / sceneID, (bool) get-all-scene-models)	table									- gets the model data table out of ModelList (returns a table with all model datas that have the same referenceID) or if bool is true from the scene
	GetModel(referenceID / sceneID, (bool) get-all-scene-models)		table									- gets all models with the same referenceID or the same sceneID (if bool is true)
	SetScene(sceneID)													nil										- sets the current scene to the sceneID given to the function
	GetScene([sceneID])													sceneID, sceneData, models, modeldatas	- gets all information of the current scene [of the sceneID]
	convert_to_16_to_9([x][,y])											x, y 									- returns the x or y (or both) input within the 16:9 resolution loginscene field (useful for mouse positions across resolutions)
	
	some helpful globals:
	ModelList.sceneCount	number	- the count of how many scenes exist
	ModelList.modelCount	number	- the count of how many models exist
]]
--[[ CREDITS:
	Made by Mordred P.H.
	
	Thanks to:
	Soldan - helping me with all the model work
	Chase - finding a method to copy cameras on the fly
	Stoneharry - bringing me to the conclusion that blizzard frames are never fullscreen, so it works with every resolution
	Blizzard - for making it almost impossible to make it work properly
]]
-------------------------------------------------------------------------
--                   1                2
--sceneData: {time_in_seconds, background_path}   --> (index is scene id)

ModelList = {
	loaded = false,									-- safety so anything else happens after loading (leave at 0)
	blend_start_duration = 1,						-- beginning fade animation duration in seconds
	max_scenes = 2,									-- number of scenes you use to shuffle through
	fade_duration = 1,								-- fade animation duration in seconds (to next scene if more than 1 exists)
	current_scene = 1,								-- current scene that gets displayed
	use_random_starting_scene = false,				-- boolean: false = always starts with sceneID 1   ||   true = starts with a random sceneID
	shuffle_scenes_randomly = false,				-- boolean: false = after one scene ends, starts the scene with sceneID + 1   ||   true = randomly shuffles the next sceneID
	login_music_path = false,						-- path to the music / false if no music
	login_ambience_name = "Weather - RainHeavy",	-- name in SoundEntries.dbc / false if no ambience
	sceneData = {
		{-1, "Interface/Loginscreen/Background.blp"},
		{-1, {0.7,0.7,0.7,1}}
	},
	
	-- Scene: 1
	{1, 1.600, 1.015, 0.000, 4.237, 0.024, 0.106, _, 1, 1, 1, "World/Expansion02/doodads/scholazar/waterfalls/sholazarsouthoceanwaterfall-06.m2", _, _},
	{1, 0.043, 0.540, 0.000, 0.000, 0.055, 1.000, _, 1, 1, 1, "Spells/Firenova_area.m2", 11, _},
	{1, 0.073, 0.540, 0.000, 0.000, 0.170, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/firewood/firewoodpile03.m2", 8, _},
	{1, -1.291, 0.478, 0.000, 2.919, 0.315, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/cargonets/deadminecargonethangshort.m2", 5, _},
	{1, -0.492, 0.198, 0.000, 0.001, 0.811, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/rugs/stormwindrug02.m2", _, _},
	{1, -0.630, 0.457, 0.000, 1.493, 0.260, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/tables/inntablesmall.m2", 15, _},
	{1, -0.653, 0.695, 0.000, 6.008, 0.223, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/bottle01.m2", 15, _},
	{1, -0.559, 0.700, 0.000, 2.964, 0.264, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle01.m2", 15, _},
	{1, -0.555, 0.693, 0.000, 0.000, 0.298, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 15, _},
	{1, -0.700, 0.693, 0.000, 5.470, 0.219, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/bottlesmoke.m2", 15, _},
	{1, -1.125, 0.431, 0.000, 1.301, 0.300, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/stoves/potbellystovewall.m2", 4, _},
	{1, -0.800, 0.000, 0.000, 0.000, 1.100, 1.000, _, 1, 10, 5, "World/generic/human/passive doodads/valves/deadminevalve.m2", 18, _},
	{1, -1.291, 0.350, 0.000, 4.491, 0.328, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/peasantlumber/peasantlumber01.m2", _, _},
	{1, -0.553, 0.685, 0.000, 3.544, 0.262, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/vials/smallvials.m2", 15, _},
	{1, -0.779, 0.689, 0.000, 5.308, 0.249, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/vials/smallvials.m2", 15, _},
	{1, 0.023, 0.898, 0.000, 3.081, 0.202, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/vials/vialsbottles.m2", 16, _},
	{1, 1.999, 5.167, -11.396, 0.000, 0.885, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/waterdrops/deadminewaterdrops.m2", 2, _},
	{1, 0.531, 0.452, 0.000, 5.925, 0.185, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/cauldrons/cauldronempty.m2", 17, _},
	{1, 0.772, 0.437, 0.000, 5.217, 0.223, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/mops/mop.m2", 17, _},
	{1, -0.422, 0.702, 0.000, 0.000, 0.264, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 15, _},
	{1, -0.239, 0.894, 0.000, 0.000, 0.298, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 16, _},
	{1, -0.218, 0.894, 0.000, 0.000, 0.236, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 16, _},
	{1, -0.171, 0.894, 0.000, 0.000, 0.298, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 16, _},
	{1, 0.294, 0.900, 0.000, 0.000, 0.292, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 16, _},
	{1, 0.335, 0.902, 0.000, 0.000, 0.226, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 16, _},
	{1, 0.235, 0.896, 0.000, 5.558, 0.159, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/bottlesmoke.m2", 16, _},
	{1, 1.073, 0.367, 0.000, 4.794, 0.322, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bookshelves/duskwoodbookshelf02.m2", 3, _},
	{1, 0.941, 0.830, 0.000, 5.334, 0.196, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/bottlesmoke.m2", 17, _},
	{1, 1.073, 0.826, 0.000, 1.865, 0.283, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/vials/vialsbottles.m2", 3, _},
	{1, 1.376, 0.209, 0.000, 1.673, 0.238, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/shopcounter/duskwoodshopcounter.m2", 3, _},
	{1, 1.071, 0.649, 0.000, 1.035, 0.230, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 17, _},
	{1, 1.024, 0.659, 0.000, 0.000, 0.215, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 17, _},
	{1, 1.047, 0.512, 0.000, 0.614, 0.230, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/greenbottle02.m2", 17, _},
	{1, 1.003, 0.521, 0.000, 0.000, 0.153, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bottles/bottle01.m2", 17, _},
	{1, 1.506, 0.433, 0.000, 5.101, 0.283, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/globes/globe01.m2", 3, _},
	{1, -1.698, 0.183, 0.000, 1.425, 0.302, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/tables/duskwoodtable01.m2", 4, _},
	{1, -1.508, 0.540, 0.000, 3.856, 0.273, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/lanterns/generallantern02.m2", 7, _},
	{1, -1.583, 0.505, 0.000, 0.983, 0.215, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bookstacks/generalbookstackshort01.m2", 6, _},
	{1, -1.404, 0.525, 0.000, 0.000, 0.258, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/bookstacks/generalbookstacktall01.m2", 4, _},
	{1, 1.340, 0.499, 0.000, 5.803, 0.010, 1.000, _, 1, 1, 1, "World/Generic/passivedoodads/scourge/nd_crashednecropolis_debri_04.m2", 3, _},
	{1, 1.295, 0.565, 0.000, 0.000, 0.006, 1.000, _, 1, 1, 1, "World/Kalimdor/silithus/passivedoodads/ahnqirajglow/quirajglow.m2", 19, _},
	{1, 1.389, 0.535, 0.000, 0.000, 0.006, 1.000, _, 1, 1, 1, "World/Kalimdor/silithus/passivedoodads/ahnqirajglow/quirajglow.m2", 19, _},
	{1, 1.235, 0.137, 0.000, 4.845, 0.415, 1.000, _, 1, 1, 1, "World/Generic/activedoodads/chests/chest01b.m2", 9, _},
	{1, -0.721, 0.395, 0.000, 3.224, 0.386, 1.000, _, 63, 1, 1, "Creature/Tempscourgemalenpc/scourgemalenpc.m2", 1, _},
	{1, 1.242, 0.357, 0.000, 0.000, 0.215, 1.000, _, 1, 1, 1, "Spells/Holy_precast_high_hand.m2", 13, _},
	{1, 1.242, 0.257, 0.000, 0.000, 0.215, 1.000, _, 1, 1, 1, "Spells/Heal_low_base.m2", 10, _},
	{1, 1.242, 0.357, 0.000, 0.000, 0.215, 1.000, _, 1, 1, 1, "Spells/Holy_impactdd_uber_chest.m2", 14, _},
	{1, 0.227, 0.873, 0.000, 0.000, 0.153, 1.000, _, 1, 1, 1, "Spells/Fire_precast_hand.m2", 12, _},
	{1, -1.632, 0.126, 0.000, 4.555, 0.362, 1.000, _, 1, 1, 1, "World/Generic/human/passive doodads/chairs/generalchairloend01.m2", 4, _},
	{1, 0.049, 1.335, 0.000, 0.000, 0.260, 1.000, _, 1, 1, 1, "World/generic/human/passive doodads/animalheads/duskwoodboarhead01.m2", 16, _},
	{1, 0.405, 0.179, 0.442, 6.277, 0.025, 1.000, _, 1, 1, 1, "World/generic/passivedoodads/floatingdebris/floatingboardsburning01.m2", 20, " "},
	
	--SmashPlayer
	{2, 0, 0.55, 0, 0, 0.08, 1, _, 1, 1, 1, "World/Expansion02/doodads/zuldrak/gundrak/gundrak_elevator_01.m2", _,_},
	{2, 0, 0, 0, 0, 0.15, 1, _, 2, 1, 1, "Creature/Medivh/medivh.m2", 1000,_}
}

-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-----------------------------------------------!!!!!!!!!!!!!!!!!!!- DO NOT CHANGE BELOW HERE, EXCEPT SCENESCRIPTS -!!!!!!!!!!!!!!!!!!!----------------------------------------------------------------
------------------------------------------------------------------!!!!!!!!!!- end of configuration part -!!!!!!!!!!-----------------------------------------------------------------------------------
-------------------------------------------------------------------------!!!- end of configuration part -!!!------------------------------------------------------------------------------------------

local timed_update, blend_timer

function randomScene()
	return (time() % ModelList.max_scenes) + 1
end

-- creates a scene object that gets used internaly
function newScene()
	local s = {parent = CreateFrame("Frame",nil,LoginScene),
				background = ModelList.sceneData[#M+1 or 1][2],
				duration = ModelList.sceneData[#M+1 or 1][1]}
	s.parent:SetSize(LoginScene:GetWidth(), LoginScene:GetHeight())
	s.parent:SetPoint("CENTER")
	s.parent:SetFrameStrata("MEDIUM")
	table.insert(M, s)
	return s
end

-- creates a new model object that gets used internally but also can be altered after loading
function newModel(parent,alpha,light,wSquish,hSquish,camera)
	local mod = CreateFrame("Model",nil,parent)
	
	light = light or {1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8}
	mod:SetModel(camera or "Character/Human/Male/HumanMale.mdx")
	mod:SetSize(LoginScene:GetWidth() / wSquish, LoginScene:GetHeight() / hSquish)
	mod:SetPoint("CENTER")
	mod:SetCamera(1)
	mod:SetLight(unpack(light))
	mod:SetAlpha(alpha)
	
	return mod
end

-- starts the routine for loading all models and scenes
function Generate_M()
	ModelList.loaded = false
	M = {}
	timed_update, blend_timer = 0, 0
	ModelList.sceneCount = #ModelList.sceneData
	
	local counter = 0
	for i=1, ModelList.sceneCount do
		local s = newScene()
		
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == i then
					table.insert(s, num, newModel(s.parent, m[7], m[8], m[10], m[11], m[14]))
					counter = counter + 1
					ModelList.lastModelNum = num
				end
			end
		end
		
		s.parent:Hide()
		if i == ModelList.current_scene then
			if type(s.background)=="table" then
				LoginScreenBackground:SetTexture(s.background[1],s.background[2],s.background[3],s.background[4])
			else
				LoginScreenBackground:SetTexture(s.background)
			end
		end
	end
	ModelList.modelCount = counter
	ModelList.loaded = true
end

------- updating and methods

function LoginScreen_OnLoad(self)
	local width = GlueParent:GetSize()
	
	if ModelList.login_ambience_name then
		PlayGlueAmbience(ModelList.login_ambience_name,5.0)
	end
	
	if ModelList.use_random_starting_scene then
		ModelList.current_scene = randomScene()
	end
	
	-- main frame for displaying and positioning of the whole loginscreen
	LoginScene = CreateFrame("Frame","LoginScene",self)
		LoginScene:SetSize(width, (width/16)*9)
		LoginScene:SetPoint("CENTER", self, "CENTER", 0,0)
		LoginScene:SetFrameStrata("LOW")
	
	-- main background that changes according to the scene
	LoginScreenBackground = LoginScene:CreateTexture("LoginScreenBackground","LOW")
		LoginScreenBackground:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginScreenBackground:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
	
	LoginScreenBlackBoarderTOP = self:CreateTexture("LoginScreenBlackBoarderTOP","OVERLAY")
		LoginScreenBlackBoarderTOP:SetTexture(0,0,0,1)
		LoginScreenBlackBoarderTOP:SetHeight(500)
		LoginScreenBlackBoarderTOP:SetPoint("BOTTOMLEFT", LoginScene, "TOPLEFT", 0,0)
		LoginScreenBlackBoarderTOP:SetPoint("BOTTOMRIGHT", LoginScene, "TOPRIGHT", 0,0)
	
	LoginScreenBlackBoarderBOTTOM = self:CreateTexture("LoginScreenBlackBoarderBOTTOM","OVERLAY")
		LoginScreenBlackBoarderBOTTOM:SetTexture(0,0,0,1)
		LoginScreenBlackBoarderBOTTOM:SetHeight(500)
		LoginScreenBlackBoarderBOTTOM:SetPoint("TOPLEFT", LoginScene, "BOTTOMLEFT", 0,0)
		LoginScreenBlackBoarderBOTTOM:SetPoint("TOPRIGHT", LoginScene, "BOTTOMRIGHT", 0,0)
	
	LoginScreenBlend = self:CreateTexture("LoginScreenBlend","OVERLAY")
		LoginScreenBlend:SetTexture(0,0,0,1)
		LoginScreenBlend:SetAllPoints(GlueParent)
	
	Generate_M()
end

function LoginScreen_OnUpdate(self,dt)
	if ModelList.loaded then
		if timed_update then
			if timed_update > 2 then
				for num, m in pairs(ModelList) do
					if type(m)=="table" and num ~= "sceneData" and m[1] <= ModelList.max_scenes then
						local mod = M[m[1]][num]
						mod:SetModel(m[12])
						mod:SetPosition(m[4], m[2], m[3])
						mod:SetFacing(m[5])
						mod:SetModelScale(m[6])
						mod:SetSequence(m[9])
					end
				end
				
				M[ModelList.current_scene].parent:Show()
				Loginscreen_OnLoad()
				Scene_OnStart(ModelList.current_scene)
				blend_start = 0
				timed_update = false
				ModelList.loaded = false
			else
				timed_update = timed_update + 1
			end
		end
	end
	
	if M then
		-- Start blend after the loginscreen loaded to hide the setting up frame
		if blend_start then
			if blend_start < ModelList.blend_start_duration then
				LoginScreenBlend:SetAlpha( 1 - blend_start/ModelList.blend_start_duration )
				blend_start = blend_start + dt
			else
				LoginScreenBlend:SetAlpha(0)
				blend_start = false
			end
		end
		
		local cur = M[ModelList.current_scene]
		if cur.duration ~= -1 then
			-- Scene and blend timer for next scene and blends between the scenes
			if cur.duration < blend_timer then
				if ModelList.max_scenes > 1 then
					local blend = blend_timer - cur.duration
					if blend < ModelList.fade_duration then
						LoginScreenBlend:SetAlpha( 1 - math.abs( 1 - (blend*2 / ModelList.fade_duration) ) )
						
						if blend*2 > ModelList.fade_duration and not nextCset then
							nextC = randomScene()
							if shuffle_scenes_randomly then
								if ModelList.current_scene == nextC then
									nextC = ((ModelList.current_scene+1 > ModelList.max_scenes) and 1) or ModelList.current_scene + 1
								end
							else
								nextC = ((ModelList.current_scene+1 > ModelList.max_scenes) and 1) or ModelList.current_scene + 1
							end
							nextCset = true
							
							local new = M[nextC]
							cur.parent:Hide()
							new.parent:Show()
							if type(new.background)=="table" then
								LoginScreenBackground:SetTexture(new.background[1],new.background[2],new.background[3],new.background[4])
							else
								LoginScreenBackground:SetTexture(new.background)
							end
							Scene_OnEnd(ModelList.current_scene)
							Scene_OnStart(nextC)
						end
						
						blend_timer = blend_timer + dt
					else
						ModelList.current_scene = nextC
						nextCset = false
						blend_timer = 0
						LoginScreenBlend:SetAlpha(0)
					end
				else
					blend_timer = 0
					Scene_OnEnd(ModelList.current_scene)
					Scene_OnStart(ModelList.current_scene)
				end
			else
				blend_timer = blend_timer + dt
			end
		end
		
		SceneUpdate(dt, ModelList.current_scene, blend_timer, ModelList.sceneData[ModelList.current_scene][1])
	end
end

function SetScene(sceneID)
	M[ModelList.current_scene].parent:Hide()
	M[sceneID].parent:Show()
	if type(M[sceneID].background)=="table" then
		LoginScreenBackground:SetTexture(M[sceneID].background[1],M[sceneID].background[2],M[sceneID].background[3],M[sceneID].background[4])
	else
		LoginScreenBackground:SetTexture(M[sceneID].background)
	end
	Scene_OnEnd(ModelList.current_scene)
	Scene_OnStart(sceneID)
	ModelList.current_scene = sceneID
end

function GetScene(sceneID)
	local curScene = ModelList.current_scene
	if sceneID then
		if sceneID <= ModelList.max_scenes and sceneID > 0 then
			curScene = sceneID
		end
	end
	return curScene, ModelList.sceneData[curScene], GetModel(curScene, true), GetModelData(curScene, true)
end

function GetModelData(refID, allSceneModels)
	local data, count = {}, 0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[13] == refID then
					table.insert(data, num, m)
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	end
end

function GetModel(refID, allSceneModels)
	local data, count = {} ,0
	if allSceneModels then
		for num, m in pairs(ModelList) do
			if type(m)=="table" and num ~= "sceneData" then
				if m[1] == refID then
					table.insert(data, num, M[m[1]][num])
					count = count + 1
				end
			end
		end
		return (count > 0 and data) or false
	else
		local mData = GetModelData(refID)
		if mData then
			for num, m in pairs(mData) do
				table.insert(data, num, M[m[1]][num])
				count = count + 1
			end
			return (count > 0 and data) or false
		else
			return false
		end
	end
end

-- overwrite GlueParent function

function SetGlueScreen(name)
	local newFrame;
	for index, value in pairs(GlueScreenInfo) do
		local frame = _G[value];
		if ( frame ) then
			frame:Hide();
			if ( index == name ) then
				newFrame = frame;
			end
		end
	end
	
	if ( newFrame ) then
		newFrame:Show();
		SetCurrentScreen(name);
		SetCurrentGlueScreenName(name);
		if ( name == "login" ) then
			if login_music_path then
				PlayMusic(login_music_path)
			end
			if login_ambience_name then
				PlayGlueAmbience(login_ambience_name,5.0)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
------									SCENE SCRIPTING PART									------
------------------------------------------------------------------------------------------------------

-- function run right after everything is set up (run before first Scene_OnStart())
function Loginscreen_OnLoad()
	LANTERN = 0
	FIRE = 0
	THUNDER = 0
	
	LoginscreenColorCorrection = AccountLogin:CreateTexture(nil,"LOW")
		LoginscreenColorCorrection:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginscreenColorCorrection:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
		LoginscreenColorCorrection:SetTexture(0.3,0.3,0.4,1)
		LoginscreenColorCorrection:SetBlendMode("MOD")
		LoginscreenColorCorrection:Hide()
	
	LoginscreenLightHit = LoginScene:CreateTexture(nil,"OVERLAY")
		LoginscreenLightHit:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginscreenLightHit:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
		LoginscreenLightHit:SetAlpha(0.2)
		LoginscreenLightHit:SetTexture("Interface/Loginscreen/LightHit.blp")
		LoginscreenLightHit:SetBlendMode("ADD")
		LoginscreenLightHit:Hide()
		
	LoginscreenHighlight = AccountLogin:CreateTexture(nil,"BACKGROUND")
		LoginscreenHighlight:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginscreenHighlight:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
		LoginscreenHighlight:SetAlpha(0.1)
		LoginscreenHighlight:SetTexture("Interface/Loginscreen/Highlight.blp")
		LoginscreenHighlight:SetBlendMode("ADD")
		LoginscreenHighlight:Hide()
		
	LoginscreenLanternGradient = AccountLogin:CreateTexture(nil,"BACKGROUND")
		LoginscreenLanternGradient:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginscreenLanternGradient:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
		LoginscreenLanternGradient:SetAlpha(0.15)
		LoginscreenLanternGradient:SetTexture("Interface/Loginscreen/LanternGradient.blp")
		LoginscreenLanternGradient:SetBlendMode("ADD")
		LoginscreenLanternGradient:Hide()
		
	LoginscreenFireGradient = AccountLogin:CreateTexture(nil,"BACKGROUND")
		LoginscreenFireGradient:SetPoint("TOPRIGHT", LoginScene, "TOPRIGHT", 0, 125)
		LoginscreenFireGradient:SetPoint("BOTTOMLEFT", LoginScene, "BOTTOMLEFT", -1, -125)
		LoginscreenFireGradient:SetAlpha(0.25)
		LoginscreenFireGradient:SetTexture("Interface/Loginscreen/FireGradient.blp")
		LoginscreenFireGradient:SetBlendMode("ADD")
		LoginscreenFireGradient:Hide()
	
	LoginscreenHighUpLight = AccountLogin:CreateFontString("LoginscreenHighUpLight", "BACKGROUND", "GlueFontNormal")
		LoginscreenHighUpLight:SetPoint("TOP", 8, -125)
		LoginscreenHighUpLight:SetText("b".."y".."   ".."M".."o".."r"..'d'..[[r]]..'e'.."d")
		LoginscreenHighUpLight:Hide()
	
	local mData = GetModelData(1,true)
	valve_timer, skull_timer = false, false
	for num,m in pairs(GetModel(1,true)) do
		m:SetLight(1, 0, 0, 0, 0, 0.6, 1.0, 0.8, 0.8, 0.5, 1.0, 0.9, 0.8)
		if mData[num][13] == 19 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
			m:SetScript("OnUpdate", function() 
				if skull_timer and skull_timer > 2 then m:SetModel("World/Generic/collision/collision_pcsize.m2"); skull_timer = false; 
				elseif skull_timer then m:SetAlpha((1 - abs(skull_timer-1))*2) end end)
		elseif mData[num][13] == 18 then
			m:SetPoint("CENTER",-480,-100)
			m:SetScript("OnUpdate", function() if valve_timer and valve_timer > 3 then m:SetModel("World/generic/human/passive doodads/valves/deadminevalve.m2"); valve_timer = false; end end)
		elseif mData[num][13] == 14 or mData[num][13] == 11 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
			m:SetScript("OnAnimFinished", function() m:SetModel("World/Generic/collision/collision_pcsize.m2") end)
		elseif mData[num][13] == 13 or mData[num][13] == 12 or mData[num][13] == 10 or mData[num][13] == 20 then
			m:SetModel("World/Generic/collision/collision_pcsize.m2")
		elseif mData[num][13] == 9 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 0.6, 0.6, 1.0)
			m:SetScript("OnUpdate", musicboxUpdate)
		elseif mData[num][13] == 8 then
			local mWidth = 220
			m:SetSize(mWidth,mWidth/16*9)
			m:SetModelScale(1)
			m:SetPoint("CENTER",10,-155)
		elseif mData[num][13] == 3 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 0.6, 0.6, 1.0)
		elseif mData[num][13] == 2 then
			m:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8)
		elseif mData[num][13] == 1 then
			m:EnableMouse(true)
			m:SetScript("OnMouseDown", mordredClicked)
			m:SetScript("OnUpdate", mordredUpdate)
			MORDRED_STATE = "USE"
		end
	end
end

-- update function that gets called each frame
local last_thunder, thunder_stage = 0, 1
local thunder_strength = random(3)
local thunder_timer = (random(3)*2)
local noChangeScene_timer = 0

function SceneUpdate(dt, sceneID, timer, sceneTime)
	if sceneID == 1 then
		timer = noChangeScene_timer
		if timer - last_thunder > thunder_timer then
			if thunder_strength == 1 then
				if thunder_stage == 1 then THUNDER = 0.2; updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.1 then THUNDER = 0; updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0.25; updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.2 then THUNDER = 0; updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 0.4 then THUNDER = 0.1; updateColorCorrect(); thunder_stage = 6;
				elseif thunder_stage == 6 and timer - last_thunder - thunder_timer > 0.45 then THUNDER = 0; updateColorCorrect(); thunder_stage = 7;
				elseif thunder_stage == 7 and timer - last_thunder - thunder_timer > 5 then
					PlaySoundFile("Interface\\Loginscreen\\Music\\Thunder_Distant.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			elseif thunder_strength == 2 then
				if thunder_stage == 1 then THUNDER = 0.4; updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.01 then THUNDER = 0; updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.1 then THUNDER = 0.1; updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0; updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 0.25 then THUNDER = 0.32; updateColorCorrect(); thunder_stage = 6;
				elseif thunder_stage == 6 and timer - last_thunder - thunder_timer > 0.27 then THUNDER = 0; updateColorCorrect(); thunder_stage = 7;
				elseif thunder_stage == 7 and timer - last_thunder - thunder_timer > 3.5 then
					PlaySoundFile("Interface\\Loginscreen\\Music\\Thunder_Mid.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			elseif thunder_strength == 3 then
				if thunder_stage == 1 then THUNDER = 0.5; updateColorCorrect(); thunder_stage = 2;
				elseif thunder_stage == 2 and timer - last_thunder - thunder_timer > 0.05 then THUNDER = 0; updateColorCorrect(); thunder_stage = 3;
				elseif thunder_stage == 3 and timer - last_thunder - thunder_timer > 0.15 then THUNDER = 0.4; updateColorCorrect(); thunder_stage = 4;
				elseif thunder_stage == 4 and timer - last_thunder - thunder_timer > 0.2 then THUNDER = 0; updateColorCorrect(); thunder_stage = 5;
				elseif thunder_stage == 5 and timer - last_thunder - thunder_timer > 1 then
					PlaySoundFile("Interface\\Loginscreen\\Music\\Thunder_Near.mp3", "Ambience")
					last_thunder = timer; thunder_timer = (random(4) + 1)*10; thunder_strength = random(3); thunder_stage = 1; end
			end
		end
		noChangeScene_timer = noChangeScene_timer + dt
	end
end

-- on end function that gets called when the scene ends
function Scene_OnEnd(sceneID)
	if sceneID == 1 then
		LoginscreenColorCorrection:Hide()
		LoginscreenLightHit:Hide()
		LoginscreenHighlight:Hide()
		LoginscreenLanternGradient:Hide()
		LoginscreenFireGradient:Hide()
		LoginscreenHighUpLight:Hide()
	end
end

-- on start function that gets called when the scene starts
function Scene_OnStart(sceneID)
	if sceneID == 1 then
		LoginscreenColorCorrection:Show()
		LoginscreenLightHit:Show()
		LoginscreenHighlight:Show()
	end
end




-- some scenescript functions

function updateColorCorrect()
	LoginscreenColorCorrection:SetTexture(0.3 + LANTERN + FIRE*3 + THUNDER,0.3 + LANTERN + FIRE*3 + THUNDER,0.4 + FIRE*2 + THUNDER,1)
	LoginscreenHighlight:SetAlpha(0.1 - (LANTERN + FIRE))
	LoginscreenLightHit:SetAlpha(0.2 - (LANTERN + FIRE)*2 + THUNDER)
end

function lanternClicked()
	LoginscreenLanternGradient:Show()
	
	local mData = GetModelData(1,true)
	for num,m in pairs(GetModel(1,true)) do
		if mData[num][13] == 4 or mData[num][13] == 18 then
			m:SetLight(1, 0, 0.5, 1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 5 then
			m:SetLight(1, 0, 0.5, 1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 6 then
			m:SetLight(1, 0, 0.5, -1, -1, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 7 then
			m:SetModel("World/Generic/human/passive doodads/lanterns/generallantern01.m2")
		end
	end
	
	LANTERN = 0.05
	updateColorCorrect()
end

function fireClicked()
	LoginscreenFireGradient:Show()
	
	local mData = GetModelData(1,true)
	for num,m in pairs(GetModel(1,true)) do
		if mData[num][13] == 8 then
			m:SetModel("World/Generic/human/passive doodads/firewood/firewoodpile01.m2")
		elseif mData[num][13] == 11 then
			m:SetModel("Spells/Firenova_area.m2")
		elseif mData[num][13] == 15 then
			m:SetLight(1, 0, -0.5, -1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 16 then
			m:SetLight(1, 0, -1, 0, 0.5, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		elseif mData[num][13] == 17 or mData[num][13] == 3 or mData[num][13] == 9 then
			m:SetLight(1, 0, -0.5, 1, 0, 0.6, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
		end
	end
	
	FIRE = 0.05
	updateColorCorrect()
end

local musicbox_timer, mbtime = false, 185
function musicboxUpdate(self, dt)
	if musicbox_timer then
		if time()-musicbox_timer >= 1.5 and not MBEFFECT then
			local mData = GetModelData(1,true)
			for num,m in pairs(GetModel(1,true)) do
				if mData[num][13] == 10 then
					m:SetModel("Spells/Heal_low_base.m2")
				elseif mData[num][13] == 13 then
					m:SetModel("Spells/Holy_precast_high_hand.m2")
				end
			end
			MBEFFECT = true
		elseif MBEFFECT and time()-musicbox_timer >= 3 then
			local mData = GetModelData(1,true)
			for num,m in pairs(GetModel(1,true)) do
				if mData[num][13] == 10 or mData[num][13] == 13 then
					m:SetSequenceTime(1,0)
				end
			end
		end
		
		if time()-musicbox_timer >= mbtime then
			local mData = GetModelData(1,true)
			for num,m in pairs(GetModel(1,true)) do
				if mData[num][13] == 9 then
					m:SetSequence(146)
				elseif mData[num][13] == 10 or mData[num][13] == 13 then
					m:SetModel("World/Generic/collision/collision_pcsize.m2")
					MBEFFECT = false
				end
			end
			StopMusic()
			musicbox_timer = false
			MUSICBOX_CLICKED = false
			MORDRED_STATE = "SIT_RETURN"
			mordred_timer = 0
		end
	end
end

function musicboxClicked()
	local num,m = next(GetModel(9))
	m:SetSequence(148)
	musicbox_timer = time()
	PlayMusic("Interface/Loginscreen/Music/dswii.mp3")
	
	local num,m = next(GetModel(14))
	m:SetModel("Spells/Holy_impactdd_uber_chest.m2")
end

function mordredClicked(self)
	local mx,my = GetCursorPosition()
	if MORDRED_STATE == "USE" then
		if mx > 0 and my < 289 and my > 197 and mx < 55 and not LANTERN_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "LANTERN"
			LANTERN_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		elseif mx > 300 and my < 470 and mx < 770 and my > 103 and not FIRE_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "FIRE"
			FIRE_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		elseif mx > 800 and my < 320 and mx < 1298 and my > 0 and not MUSICBOX_CLICKED and FIRE_CLICKED and LANTERN_CLICKED and MORDRED_STATE == "USE" then
			MORDRED_STATE = "MUSICBOX"
			MUSICBOX_CLICKED = true
			mordred_timer = 0
			mordred_stage = 1
		end
	end
	if not valve_timer then
		if mx > 138 and mx < 168 and my > 225 and my < 250 then
			local num,m = next(GetModel(18))
			m:SetModel("World/generic/human/passive doodads/valvesteam/deadminevalvesteam02.m2")
			valve_timer = 0
		end
	end
	if not skull_timer then
		if mx > 1199 and mx < 1287 and my > 156 and my < 220 then
			for num,m in pairs(GetModel(19)) do
				m:SetModel("World/Kalimdor/silithus/passivedoodads/ahnqirajglow/quirajglow.m2")
			end
			skull_timer = 0
		end
	end
	if skull_timer and valve_timer then
		if mx > 646 and mx < 734 and my > 509 and my < 618 then
			local num,m = next(GetModel(20))
			m:SetModel("World/generic/passivedoodads/floatingdebris/floatingboardsburning01.m2")
			LoginscreenHighUpLight:Show()
		end
	end
end

-- MOVEMENT EVENTS

function mUse(timer, dt)
	if timer > 0.5 then
		local num,m = next(GetModel(1))
		m:SetSequenceTime(63,1700)
		mordred_timer = -dt
		if random((time()%100)+1) == 1 then
			MORDRED_STATE = "USE_DRINK"
		end
	end
end

function mUseDrink(timer, dt)
	if timer > 5.5 and not DRINKING then
		local num,m = next(GetModel(1))
		m:SetSequence(63)
		MORDRED_STATE = "USE"
		mordred_timer = -dt
		DRINKING = false
	elseif timer > 4.5 and DRINKING then
		local num,m = next(GetModel(1))
		m:SetSequence(8)
		DRINKING = false
	elseif timer > 1.5 and timer < 4 and not DRINKING then
		local num,m = next(GetModel(1))
		m:SetSequence(61)
		DRINKING = true
	end
end

function mLantern(timer, dt)
	local num,m = next(GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 6.2 then m:SetFacing(m:GetFacing() + 0.04)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if z < 0.6 then m:SetPosition(z+0.006,x-0.0025,y-0.001)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 5 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(63); mAnim_set = nil; mStartA = timer; end
		if timer - mStartA > 3.5 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.75 and mAnim_set == nil then lanternClicked(); mAnim_set = true; end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 3.2 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 6; mAnim_set = false; m:SetFacing(3.224); end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if z > 0 then m:SetPosition(z-0.006,x+0.0028,y+0.0011)
		else mAnim_set = false; MORDRED_STATE = "USE"; m:SetSequence(63); local num,mD = next(GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); end
	end
end

function mFire(timer, dt)
	local num,m = next(GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 1.7 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x < 0 then m:SetPosition(z,x+0.012,y)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < math.pi then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(52); mAnim_set = nil; mStartA = timer;
		local num,mC = next(GetModel(12)); mC:SetModel("Spells/Fire_precast_hand.m2"); end
		if timer - mStartA > 3 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.5 and mAnim_set == nil then m:SetSequence(54); mAnim_set = true; fireClicked();
		local num,mC = next(GetModel(12)); mC:SetModel("World/Generic/collision/collision_pcsize.m2"); end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 5 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 6; mAnim_set = false; end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x > -0.721 then m:SetPosition(z,x-0.012,y)
		else local num,mD = next(GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); mordred_stage = 7; mAnim_set = false; end

	elseif mordred_stage == 7 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 3.224 then m:SetFacing(m:GetFacing() - 0.03)
		else mAnim_set = false; m:SetFacing(3.224); MORDRED_STATE = "USE"; m:SetSequence(63); end
	end
end

function mMusicBox(timer, dt)
	local num,m = next(GetModel(1))
	if mordred_stage == 1 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > 1 then m:SetFacing(m:GetFacing() - 0.03)
		else mordred_stage = 2; mAnim_set = false; end

	elseif mordred_stage == 2 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x < 0.5 then m:SetPosition(z+0.006,x+0.01,y-0.0006)
		else mordred_stage = 3; mAnim_set = false; end

	elseif mordred_stage == 3 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 1.55 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 4; mAnim_set = false; end

	elseif mordred_stage == 4 then
		if mAnim_set == false then m:SetSequence(50); mAnim_set = nil; mStartA = timer; end
		if timer - mStartA > 3 then mordred_stage = 5; mAnim_set = false;
		elseif timer - mStartA > 1.5 and mAnim_set == nil then musicboxClicked(); mAnim_set = true;
		elseif timer - mStartA > 1.5 and mAnim_set then m:SetSequenceTime(50, (3-(timer - mStartA))*1000); end

	elseif mordred_stage == 5 then
		if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
		if m:GetFacing() < 3.5 then m:SetFacing(m:GetFacing() + 0.03)
		else mordred_stage = 6; mAnim_set = false; end

	elseif mordred_stage == 6 then
		if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
		local z,x,y = m:GetPosition()
		if x > 0.04 then m:SetPosition(z-0.006,x-0.004,y+0.00065)
		else local num,mD = next(GetModelData(1)); m:SetPosition(mD[4],0.04,mD[3]); mordred_stage = 7; mAnim_set = false; end

	elseif mordred_stage == 7 then
		if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
		if m:GetFacing() > math.pi then m:SetFacing(m:GetFacing() - 0.01)
		else mordred_stage = 8; mAnim_set = false; end

	elseif mordred_stage == 8 then
		if not mAnim_set then m:SetSequence(96); MORDRED_STATE = "SIT"; mordred_timer = 0; mordred_stage = 1; end
	end
end

function mSitReturn(timer, dt)
	if timer > 2 then
		local num,m = next(GetModel(1))
		if mordred_stage == 1 then
			if not mAnim_set then m:SetSequence(98); mAnim_set = true; mStartA = timer; end
			if timer - mStartA > 1.5 then mordred_stage = 2; mAnim_set = false; end
	
		elseif mordred_stage == 2 then
			if not mAnim_set then m:SetSequence(11); mAnim_set = true; end
			if m:GetFacing() < 5 then m:SetFacing(m:GetFacing() + 0.02)
			else mordred_stage = 3; mAnim_set = false; end
	
		elseif mordred_stage == 3 then
			if not mAnim_set then m:SetSequence(4); mAnim_set = true; end
			local z,x,y = m:GetPosition()
			if x > -0.721 then m:SetPosition(z,x-0.012,y)
			else local num,mD = next(GetModelData(1)); m:SetPosition(mD[4],mD[2],mD[3]); mordred_stage = 4; mAnim_set = false; end
	
		elseif mordred_stage == 4 then
			if not mAnim_set then m:SetSequence(12); mAnim_set = true; end
			if m:GetFacing() > 3.224 then m:SetFacing(m:GetFacing() - 0.03)
			else mAnim_set = false; m:SetFacing(3.224); MORDRED_STATE = "USE"; m:SetSequence(63); mordred_timer = 0; end
		end
	end
end

mordred_timer = 0
function mordredUpdate(self, dt)
	if MORDRED_STATE == "USE" then
		mUse(mordred_timer, dt)
	elseif MORDRED_STATE == "USE_DRINK" then
		mUseDrink(mordred_timer, dt)
	elseif MORDRED_STATE == "LANTERN" then
		mLantern(mordred_timer, dt)
	elseif MORDRED_STATE == "FIRE" then
		mFire(mordred_timer, dt)
	elseif MORDRED_STATE == "MUSICBOX" then
		mMusicBox(mordred_timer, dt)
	elseif MORDRED_STATE == "SIT_RETURN" then
		mSitReturn(mordred_timer, dt)
	end
	
	if MORDRED_STATE ~= "USE" and MORDRED_STATE ~= "SIT" and FIRE > 0 then
		updateMordredLight()
	end
	
	mordred_timer = mordred_timer + dt
	if valve_timer then valve_timer = valve_timer + dt; end
	if skull_timer then skull_timer = skull_timer + dt; end
end

function updateMordredLight()
	local num,m = next(GetModel(1))
	local z,x,y = m:GetPosition()
	m:SetLight(1, 0, 0.4, x*2, 0, 0.4, 1.0, 0.8, 0.8, 1.0, 1.0, 0.6, 0.6)
end








