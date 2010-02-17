nFilter = CreateFrame("Frame", "ncd")
nFilter:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
nFilter:RegisterEvent('ADDON_LOADED')

--[[ Config section ]]--

local oocAlpha = 0 -- poorly named.  Really it's the alpha when the spell is off cooldown or buff/debuff not present
local icAlpha = 1 -- again badly named.  Alpha when spell is on cooldown or buff/debuff is present.
local showTimer = true
local fontsize = 10
local delay = 1

local stackFont = "Interface\\Addons\\media\\frames\\COLLEGIA.ttf" -- Font used for stack counts.

function nFilter:ADDON_LOADED(event, name)
	if(name == 'nFilter') then
        createFrames()
	end
end

--[[
    Settings for spells:
    
    frameName, spellID, [mine], unit, size, posx, posy, frame strata, anchor, [filter]
    frameName must be unique
    [mine] is only for buffs/debuffs
	[filter] is a UnitAura() appropriate filter (usually either HARMFUL or HELPFUL)

]]--
pname = UnitName("player")


-- Create the frame to hold stuff
function createFrames()
    for k,v in ipairs(nFilter.spellList.buffs) do
        createBuffFrame(unpack(v))
    end
    
    for k,v in ipairs(nFilter.spellList.cooldowns) do
        createCooldownButton(unpack(v))
    end
end

function createCooldownButton(frameName, spellID, size, posx, posy, strata, anchor)
	local spellName, spellRank, SpellIcon, SpellCost, spellIsFunnel, spellPowerType, spellCastTime, spellMinRange, spellMaxRange = GetSpellInfo(spellID)
	local f = CreateFrame("Frame", "nFilter_"..frameName, nFilter)
    f:SetParent(nFilter)
    f:SetFrameStrata(strata)
    f:SetHeight(size)
    f:SetWidth(size)
    f:SetPoint("CENTER", anchor, "CENTER", posx, posy)
    
    f.tex = f:CreateTexture()
    f.tex:SetTexture(SpellIcon)
    f.tex:SetAllPoints(f)
    f.tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    f.tex:SetDesaturated(true)
    
	local cdFrame = CreateFrame("Frame", nil, f)
	cdFrame:SetAllPoints(f)
	cdFrame:SetFrameStrata("MEDIUM")
	
	local cd = cdFrame:CreateFontString("bCD","OVERLAY")
	cd:SetFont(stackFont,size/1.8,"OUTLINE")
	cd:SetPoint("CENTER", f, "BOTTOM", 0, 5)
	cd:SetTextColor(1,1,1,1)
	
	local border = f:CreateTexture(nil,"LOW")
    border:SetTexture("Interface\\AddOns\\media\\frames\\aura")
    border:SetVertexColor(0.37,0.3,0.3)
	border:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    border:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
    f.texture = border
	
    f.cooldown = CreateFrame("Cooldown", nil, f)
    f.cooldown:SetAllPoints(f)
	f.cooldown:SetFrameStrata("LOW")
	f.cooldown:SetAlpha(0.7)
    f.spellID = spellID
    f.spellName = spellName
	f.cd = cd
	f.launch = floor(GetTime())
	f:Show()
	
	local del = delay
    f.OnUpdate = function(self, elapsed)
		del = del - elapsed
		if( del < 0 ) then
			local start, duration, enable = GetSpellCooldown(self.spellName)
			if( duration ~= nil and duration > 1.5 and enable == 1 ) then
				local cur = floor(start+duration-GetTime()+0.5)
				self:SetAlpha(icAlpha)
				if(showTimer) then
					self.cd:SetText(cur)
				end
				self.tex:SetDesaturated(false)
				CooldownFrame_SetTimer(self.cooldown, start, duration, enable)
				if(cur > 10) then cd:SetTextColor(1,1,1,1)
				else cd:SetTextColor(1,0.3,0,1) cd:SetFont(stackFont,size/1.5,"OUTLINE")
				end
			else
				self.tex:SetDesaturated(true)
				self:SetAlpha(oocAlpha)
				self.cd:SetText()
			end
		del = 1
		end
	end
	
	f.OnEvent = function(self, event) 
		if(event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
			if(IsSpellKnown(self.spellID)) then
				self:Show()
				self:SetAlpha(oocAlpha)
			else
				self:Hide()
			end
		end
	end
	
	f:RegisterEvent"PLAYER_REGEN_ENABLED"
	f:RegisterEvent"ACTIVE_TALENT_GROUP_CHANGED"
	f:RegisterEvent"PLAYER_REGEN_DISABLED"
	f:RegisterEvent"PLAYER_ENTERING_WORLD"
    
    f:SetScript("OnUpdate", f.OnUpdate)
	f:SetScript("OnEvent", f.OnEvent)
end

function createBuffFrame(frameName, spellID, mine, unit, size, posx, posy, strata, anchor, filter)
    local f = CreateFrame("Frame", "nFilter_"..frameName, nFilter)
    f:SetParent(nFilter)
    f:SetFrameStrata(strata)
    f:SetHeight(size)
    f:SetWidth(size)
    f:SetPoint("CENTER", anchor, "CENTER", posx, posy)
    
    f.tex = f:CreateTexture()
    f.tex:SetAllPoints(f)
    f.tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    f.tex:SetDesaturated(true)
    
	local border = f:CreateTexture(nil,"LOW")
    border:SetTexture("Interface\\AddOns\\media\\nfilter\\gloss")
    border:SetVertexColor(0.37,0.3,0.3)
    border:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 0)
    border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, 0)
    f.texture = border
	
    f.cooldown = CreateFrame("Cooldown", nil, f)
    f.cooldown:SetAllPoints(f)
	f.cooldown:SetAlpha(1)
	
	local tf = CreateFrame("Frame", nil, f)
	tf:SetParent(f)
	tf:SetFrameStrata("MEDIUM")
	tf:SetAllPoints(f)	
	
	local count = tf:CreateFontString(nil, "OVERLAY")
	count:SetFont(stackFont, size/2, "OUTLINE")
	count:SetPoint("RIGHT", tf, "BOTTOMRIGHT", 0, size/5)
	count:SetTextColor(1,1,1)
	f.count = count
   
	local timer = tf:CreateFontString(nil, "OVERLAY")
	timer:SetFont(stackFont, size/2, "OUTLINE") 
	timer:SetPoint("TOPLEFT", tf, "TOPLEFT", -2, 2)
	timer:SetTextColor(1,1,1)
	f.timer = timer
	
    f.spellID = spellID
    f.spellName = nil
    f.unit = unit
	f.size = size
    f.updateTime = 0
	f.filter = filter
	f.force = false
	f.launch = floor(GetTime())
	f.mine = mine
	f:Show()
	
    f.onEvent = function(self, event)
		if( event == "PLAYER_REGEN_DISABLED" ) then self:Show() end
		if( self.spellName == nil ) then
            local spellName, _, icon, _, _, _, _, _, _ = GetSpellInfo(self.spellID)
            self.spellName = spellName
			self.tex:SetTexture(icon)
			self.tex:SetDesaturated(true)
		end
        for i = 1, 40 do
            local name, _, icon, count, _, duration, expirationTime, unitCaster, _ = UnitAura(self.unit, i, self.filter)
			local casterCheck
			if( self.mine and unitCaster == 'player') then
				casterCheck = true
			else
				casterCheck = not self.mine
			end
			if( name == self.spellName and casterCheck) then
				self.tex:SetDesaturated(false)
				self:SetAlpha(icAlpha)
				self.updateTime = expirationTime
				if( count > 1 ) then
					self.count:SetText(count)
				else
					self.count:SetText("")
				end
				CooldownFrame_SetTimer(self.cooldown, expirationTime - duration, duration, 1)
				
				if( not self:IsShown() ) then self:Show() end
				return
			elseif( i == 40 ) then
				CooldownFrame_SetTimer(self.cooldown, 0, 0, 0)
				self.updateTime = 0
				self:SetAlpha(oocAlpha)
				self.tex:SetDesaturated(true)
				self:Hide()
			end
        end
    end

	local del = delay
	f.OnUpdate = function(self, elapsed) 
		del = del - elapsed
		if( del < 0 ) then
			for i = 1, 40 do
				local spellName = select(1, GetSpellInfo(self.spellID))
				local name, _, icon, count, _, duration, expiration, unitCaster, _ = UnitAura(self.unit, i, self.filter)
				if(name == spellName) then 
					if(expiration) then 
						local timer = floor(expiration) - floor(GetTime())
						if ( timer > 0 ) then self.timer:SetText( timer )
						else 
							self.timer:SetText("")
						end
					end
				end
			end
			del = 1
		end
	end
   
    f:RegisterEvent"UNIT_AURA"
    f:RegisterEvent"PLAYER_TARGET_CHANGED"
	f:RegisterEvent"PLAYER_REGEN_ENABLED"
	f:RegisterEvent"PLAYER_REGEN_DISABLED"
	f:RegisterEvent"PLAYER_ENTERING_WORLD"
    
    f:SetScript("OnEvent", f.onEvent)
	f:SetScript("OnUpdate", f.OnUpdate)
end
