
WTib = WTib or {}

function WTib.Render(a)
	if Wire_Render then Wire_Render(a) end
	if WTib.HasRD3() then
		WTib.RD3.Beam_Render(a)
	end
end
