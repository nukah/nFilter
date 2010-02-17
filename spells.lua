local class = select(2,UnitClass("player"))

--[[
	format:
		cooldown-name, spell-id, isMine, unit, size, position-x, position-y, strata, parent, filter
		
		cooldown-name: Name of spell, produced buff/cooldown frame(for future parenting) is called nFilter_<cooldown-name>
		spell-id: spell id or itemslot
		isMine: is it player's buff
		unit: player,target,focus, etc: http://www.wowwiki.com/Units
		size: size of frame
		position-x: obvious
		position-y: obvious
		strata: http://www.wowwiki.com/UITYPE_FrameStrata
		parent: parent frame
		filter: http://www.wowwiki.com/API_UnitAura
		
		available item slots: { 
			HeadSlot
			FeetSlot
			Finger1Slot
			Finger2Slot
			Trinket1Slot
			Trinket2Slot
			HandsSlot
			BackSlot
			}
		
		spell cooldown:: [4] = {'innerfocus', 14751, "player", 14, 20, 0, "LOW", "nFilter_guardianspirit"},
		
		
]]--

if(class == "PRIEST") then

nFilter.spellList = {
	buffs = {
		[1] = {'serendipity', 63734, true, "player", 15, -72, -120, "LOW", "UIParent", "HELPFUL"},
		[2] = {'surgeoflight', 33151, true, "player", 15, 25, 0, "LOW", "nFilter_serendipity", "HELPFUL"},
		[3] = {'instability', 69766, false, "player", 26, 30, 40, "LOW", "UIParent", "HARMFUL"},
		[4] = {'buffet', 70127, false, "player", 26, -30, 40, "LOW", "UIParent", "HARMFUL"},
		[5] = {'plague', 70337, false, "target", 26, 0, 40, "LOW", "UIParent", "HARMFUL"},
		
	},
	cooldowns = {
		[1] = {'divinehymn', 64843, 14, -26, -295, "LOW", "UIParent"},
		[2] = {'hymnofhope', 64901, 14, 20, 0, "LOW", "nFilter_divinehymn"},
		[3] = {'guardianspirit', 47788, 14, 20, 0, "LOW", "nFilter_hymnofhope"},
		[4] = {'innerfocus', 14751, 14, 20, 0, "LOW", "nFilter_guardianspirit"},
		[5] = {'shadowfiend', 34433, 14, 0, -24, "LOW", "nFilter_innerfocus"},
		[6] = {'painsuppresion', 33206, 14, 0, -24, "LOW", "nFilter_hymnofhope"},
		[7] = {'powerinfusion', 10060, 14, 20, 0, "LOW", "nFilter_hymnofhope"}, 
		[8] = {'torrent', 28730, 14, 0, -24, "LOW", "nFilter_guardianspirit"}, 
		[9] = {'pscream', 10890, 14, 0, -24, "LOW", "nFilter_hymnofhope"}, 
		[10] = {'dprayer', 48173, 14, -20, 0, "LOW", "nFilter_pscream"}, 
		
	},
}

end

if(class == "DEATHKNIGHT") then

nFilter.spellList = {
	buffs = {
		[1] = {'bloodplague', 59879, true, "target", 18, -71, -188, "LOW", "UIParent", "HARMFUL"},
		[2] = {'frostfever', 59921, true, "target", 18, 21, 0, "LOW", "nFilter_bloodplague", "HARMFUL"},
		
	},
	cooldowns = {
		[1] = {'krovo', 45529, "player", 14, -37, -270, "LOW", "UIParent"},
	},
}

end