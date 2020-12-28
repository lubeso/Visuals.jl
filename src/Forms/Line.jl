include("Form.jl")
include("Layer.jl")
using NamedColors
using Measures
import Compose, Cairo, Fontconfig
BACKGROUND = (Compose.context(), Compose.rectangle(), Compose.fill(colorant"beige"))


# form
# ---
mutable struct Line <: Form

	ps::Vector{Tuple{T, T}} where T <: Union{Real, Length}
	
	style::Vector

	Line(ps; style=[]) = new(ps, style)
end

# layer
# ---
function Layer(l::Line)

	layer = (Compose.context(), 
		 Compose.line(l.ps), p.style...,
		 Compose.linewidth(0.25mm),
		 Compose.stroke(colorant"wine"))

	return layer

end

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm); dt = 1e-2
	ps = [(
	       0.25 + 0.5t,
	       0.25sin(5π*t) + 0.5
	) for t in 0:dt:1]
	l = Line(ps)
	layer = Layer(l)
	frame = render([layer, BACKGROUND])
	frame |> Compose.PDF("gallery/Line.pdf")
end
