
local AccountLogin_OnKeyDown_SAVED = AccountLogin_OnKeyDown
local AccountLogin_Login_SAVED = AccountLogin_Login
local Scene_OnStart_SAVED = Scene_OnStart

LSToolsButton = CreateFrame("Button",nil,AccountLogin,"GlueButtonSmallTemplateBlue")
	LSToolsButton:SetText("Smash")
	LSToolsButton:SetPoint("BOTTOM", OptionsButton, "TOP", 0, 0)
	LSToolsButton:SetFrameStrata("HIGH")
	LSToolsButton:SetScript("OnClick", function()
			SetScene(2)
			AccountLogin_Login = function() end
			AccountLoginPasswordEdit:Hide()
			AccountLoginAccountEdit:Hide()
		end)

local PLAYER = {};
function Scene_OnStart(sceneID)
	Scene_OnStart_SAVED(sceneID)
	
	if sceneID == ModelList.sceneCount then
		local num,m = next(GetModel(1000))
		m:SetPosition(0,-0.5,0.58)
		
		PLAYER = {
			x_vel = 0,
			y_vel = 0,
			x_max = 0.02,
			y_max = 0.04,
			anim = 2,
			double_jump = false,
			ledged = false,
			strata = m:GetFrameLevel()
		}
		
		m:SetScript("OnAnimFinished", function()
			if PLAYER.anim == 37 then
				PlayerSetAnim(m,38)
			end
		end)
	end
end

-- MAIN PART

local MOVE_HOLDING = "STAND"
local ON_PLATFORM = true
local JUMP_FROM_PLATFORM = false
local JUMP_FROM_LEDGE = false

function AccountLogin_OnKeyDown(key)
	if key == "RIGHT" or key == "LEFT" or key == "UP" or key == "DOWN" and not JUMP_FROM_LEDGE then
		MOVE_HOLDING = key
	elseif key == "SPACE" and ON_PLATFORM then
		local num,m = next(GetModel(1000))
		PLAYER.y_vel = 0.02
		ON_PLATFORM = false
		JUMP_FROM_PLATFORM = true
		PlayerSetAnim(m,37)
	elseif key == "SPACE" and PLAYER.double_jump then
		local num,m = next(GetModel(1000))
		PLAYER.y_vel = 0.02
		PLAYER.double_jump = false
		JUMP_FROM_PLATFORM = true
		PlayerSetAnim(m,37)
	elseif key == "SPACE" and JUMP_FROM_LEDGE then
		local num,m = next(GetModel(1000))
		PLAYER.y_vel = 0.025
		JUMP_FROM_LEDGE = false
		PlayerSetAnim(m,37)
		PLAYER.double_jump = true
	elseif key == "DOWN" and JUMP_FROM_LEDGE then
		local num,m = next(GetModel(1000))
		PLAYER.y_vel = 0
		JUMP_FROM_LEDGE = false
		PlayerSetAnim(m,38)
		PLAYER.double_jump = true
	end
end

AccountLogin:SetScript("OnKeyUp", function(self, key)
		if key == MOVE_HOLDING then
			MOVE_HOLDING = "STAND"
		end
	end)

function updatePlayerStats(m, dt)
	local pZ,pX,pY = m:GetPosition()
	if pY < 0.7 and pY > 0.5 and pX > -1 and pX < 1 then
		m:SetFrameLevel(PLAYER.strata)
	else
		m:SetFrameLevel(1)
	end
	
	if pY == 0.58 and pX > -1 and pX < 1 then
		ON_PLATFORM = true
		PLAYER.double_jump = true
		PLAYER.y_vel = 0
	elseif PLAYER.y_vel > -PLAYER.y_max and (not PLAYER.ledged or not JUMP_FROM_LEDGE) then
		ON_PLATFORM = false
		PLAYER.y_vel = PLAYER.y_vel - dt/25
		if MOVE_HOLDING == "DOWN" then
			PLAYER.y_vel = PLAYER.y_vel - dt/25
		end
		if PLAYER.y_vel > 0 and (pX > -0.9 and pX < 0.9 and pY > 0.25 and pY < 0.5) then
			PLAYER.y_vel = 0
		elseif ((pX < -0.9 and pX > -1.05) or (pX > 0.9 and pX < 1.05)) and pY > 0.1 and pY < 0.25 and not PLAYER.ledged then
			if pX < 0 then
				MOVE_HOLDING = "LEDGE_LEFT"
				m:SetFacing(math.pi/2)
				m:SetPosition(pZ,-1.02,0.23)
			elseif pX > 0 then
				MOVE_HOLDING = "LEDGE_RIGHT"
				m:SetFacing(-math.pi/2)
				m:SetPosition(pZ,1.02,0.23)
			end
			PLAYER.y_vel = 0
			PLAYER.x_vel = 0
			JUMP_FROM_LEDGE = true
			PLAYER.ledged = true
			PLAYER.double_jump = false
			PlayerSetAnim(m, 125)
		elseif pY > 0.3 or pY < 0.1 then
			PLAYER.ledged = false
		end
	end
	
	if pY <= 0.58 and pY > 0.5 and pX > -1 and pX < 1 and not JUMP_FROM_PLATFORM then
		m:SetPosition(pZ,pX,0.58)
		PLAYER.y_vel = 0
		ON_PLATFORM = true
		PLAYER.double_jump = true
	elseif JUMP_FROM_PLATFORM and PLAYER.y_vel < 0 then
		JUMP_FROM_PLATFORM = false
	end
	
	if (MOVE_HOLDING == "STAND" or MOVE_HOLDING == "DOWN" or MOVE_HOLDING == "UP") and ON_PLATFORM and (not PLAYER.ledged or not JUMP_FROM_LEDGE) then
		if PLAYER.x_vel ~= 0 then
			PLAYER.x_vel = 0
		elseif PLAYER.x_vel > 0 then
			PLAYER.x_vel = PLAYER.x_vel - dt/10
		elseif PLAYER.x_vel < 0 then
			PLAYER.x_vel = PLAYER.x_vel + dt/10
		end
	end
	
	if MOVE_HOLDING == "LEFT" and PLAYER.x_vel > -PLAYER.x_max and (not PLAYER.ledged or not JUMP_FROM_LEDGE) then
		PLAYER.x_vel = PLAYER.x_vel - dt/25
		if PLAYER.x_vel > 0 and ON_PLATFORM then
			PLAYER.x_vel = PLAYER.x_vel - dt/5
		end
	elseif MOVE_HOLDING == "RIGHT" and PLAYER.x_vel < PLAYER.x_max and (not PLAYER.ledged or not JUMP_FROM_LEDGE) then
		PLAYER.x_vel = PLAYER.x_vel + dt/25
		if PLAYER.x_vel < 0 and ON_PLATFORM then
			PLAYER.x_vel = PLAYER.x_vel + dt/5
		end
	end
	
	--collision left and right
	if pX < 1 and pX > -1 and pY < 0.5 and pY > 0.25 then
		if PLAYER.x_vel > 0 and pX < 0 then
			PLAYER.x_vel = 0
		elseif PLAYER.x_vel < 0 and pX > 0 then
			PLAYER.x_vel = 0
		end
	end
end

function PlayerSetAnim(m,anim)
	if anim == 37 or PLAYER.anim ~= anim then
		m:SetSequence(anim)
		PLAYER.anim = anim
	end
end

LSToolsButton:SetScript("OnUpdate", function(self, dt)
		if current_scene == ModelList.sceneCount then
			local num,m = next(GetModel(1000))
			updatePlayerStats(m, dt)
			
			local pZ,pX,pY = m:GetPosition()
			
			m:SetPosition(pZ, pX + PLAYER.x_vel, pY + PLAYER.y_vel)
			
			if ON_PLATFORM then
				if PLAYER.ledged then
					PlayerSetAnim(m, 125)
				elseif (PLAYER.x_vel > 2*PLAYER.x_max/3 or PLAYER.x_vel < -2*PLAYER.x_max/3) then
					PlayerSetAnim(m, 143)
				elseif PLAYER.x_vel > PLAYER.x_max/3 or PLAYER.x_vel < -PLAYER.x_max/3 then
					PlayerSetAnim(m, 5)
				elseif PLAYER.x_vel > 0 or PLAYER.x_vel < 0 then
					PlayerSetAnim(m, 4)
				elseif MOVE_HOLDING == "DOWN" then
					PlayerSetAnim(m, 120)
				else
					PlayerSetAnim(m, 2)
				end
			end
			
			if MOVE_HOLDING == "RIGHT" and not PLAYER.ledged then
				m:SetFacing(math.pi/2)
			elseif MOVE_HOLDING == "LEFT" and not PLAYER.ledged then
				m:SetFacing(-math.pi/2)
			end
			
			--DEBUG RESET
			if pY < -5 then
				m:SetPosition(pZ,0,0.58)
			end
		end
	end)
















