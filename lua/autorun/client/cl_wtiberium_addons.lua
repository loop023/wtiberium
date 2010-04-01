
WTib = WTib or {}

function WTib.Render(a)
	if Wire_Render then Wire_Render(a) end
	WTib.HasRD3()
		WTib.RD3.Beam_Render(a)
	end
end
