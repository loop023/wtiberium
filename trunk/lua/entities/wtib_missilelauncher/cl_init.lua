include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	WTib_Render(self)
end

function ENT:WTib_GetTooltip()
	local loaded = "No"
	if self:GetNWBool("Loaded") then
		loaded = "Yes"
	end
	return "Tiberium Missile Launcher\nLoaded : ("..loaded..")"
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
		self.NextRBUpdate = CurTime()+2
		WTib_UpdateRenderBounds(self)
	end
end
language.Add("wtib_missilelauncher","Missile Launcher")
