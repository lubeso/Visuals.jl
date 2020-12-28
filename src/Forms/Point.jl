include("Form.jl")
include("Layer.jl")
using NamedColors
using Measures
import Compose, Cairo, Fontconfig
BACKGROUND = (Compose.context(), Compose.rectangle(), Compose.fill(colorant"beige"))


# form
# ---
mutable struct Point <: Form

	x::T where T <: Union{Real, Length}
	y::T where T <: Union{Real, Length}
	
	style::Vector

	Point(x, y; style=[]) = new(x, y, style)
end

# layer
# ---
function Layer(p::Point)

	layer = (Compose.context(), 
		 Compose.circle(p.x, p.y, 3.5pt), p.style...,
		 Compose.fill(colorant"wine"))

	return layer

end

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm)
	p = Point(0.5, 0.5)
	layer = Layer(p)
	frame = render([layer, BACKGROUND])
	frame |> Compose.PDF("gallery/Point.pdf")
end
