include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	Wire_Render(self)
end

function ENT:Think()
	if CurTime() >= (self.NextRBUpdate or 0) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self)
	end
end
language.Add("wtib_tibrefinery","Tiberium Refinery")
