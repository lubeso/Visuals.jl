include("Form.jl")
include("Layer.jl")
using Measures, NamedColors
import Compose, Cairo, Fontconfig

# method: form declaration
# ---
mutable struct Point <: Form
	# fields
	x::Union{Real, Length}
	y::Union{Real, Length}

	# kwargs
	size::Union{Real, Length}
	style::Vector

	# constructor
	Point(x, y; size=3.5pt, style=[]) = new(x, y, size, style)
end

# method: Point form -> Point layer
# ---
function Layer(p::Point, config::Compose.Context)

	layer = (
		config, 
		Compose.circle(p.x, p.y, p.size), 
		p.style...,
		Compose.fill(colorant"beige")
	)

	return layer

end

Layer(p::Point; context=Compose.context()) = Layer(p, context)

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm)
	BACKGROUND = (
		Compose.context(), 
		Compose.rectangle(), 
		Compose.fill(colorant"Licorice")
	)
	y = t -> 0.25sin(2*π*t) / (1 + t)^2 + 0.5
	points = Point[]
	for x₀ in [0.25, 0.5, 0.65]
		x = t -> x₀ + (0.75 - x₀) * t
		push!(points, [Point(x(t), y(t), size=0.5mm) for t ∈ 0.0:0.05:1.0]...)
	end
	layers = Layer.(points)
	image  = render([layers..., BACKGROUND])
	image  |> Compose.PDF("gallery/Point.pdf")
end
