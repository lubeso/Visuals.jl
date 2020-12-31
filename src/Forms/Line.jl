include("Form.jl")
include("Layer.jl")
using Measures, NamedColors
import Compose, Cairo, Fontconfig


# method: form declaration
# ---
mutable struct Line <: Form
	# fields
	points::Vector

	# kwargs
	lw::Length
	style::Vector

	# constructor
	Line(points::Vector; lw=0.25mm, style=[]) = new(points, lw, style)
end

# method: Line form -> Line layer
# ---
function Layer(l::Line, config::Compose.Context)

	layer = (
		config, 
		Compose.line(l.points), 
		l.style...,
		Compose.linewidth(l.lw),
		Compose.stroke(colorant"beige")
	)

	return layer

end

Layer(l::Line; config=Compose.context()) = Layer(l, config)

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm); dt = 1e-2
	BACKGROUND = (
		Compose.context(),
		Compose.rectangle(),
		Compose.fill(colorant"Licorice")
	)
	x = t -> 0.25 + 0.5t
	lines = Line[]
	for y₀ in 0.25:0.05:0.75
		y = t -> y₀ - (t - 0.55)^3 
		push!(lines, Line([(x(t), y(t)) for t ∈ 0.0:0.05:1.0]))
	end
	layers = Layer.(lines)
	image  = render([layers..., BACKGROUND])
	# image  |> Compose.PDF("gallery/Line.pdf")
end
