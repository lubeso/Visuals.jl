begin
	DIR = "../../src/Forms"
	include("$DIR/Layer.jl")
	include("$DIR/Form.jl")
	include("$DIR/Point.jl")
	include("$DIR/Line.jl")
	include("$DIR/Arc.jl")
	using Measures, NamedColors, ColorBlendModes, ColorBlendModes, ColorBlendModes, ColorBlendModes
	import Compose, Cairo, Fontconfig
end

# canvas
begin
	Compose.set_default_graphic_size(10cm, 10cm)
	BG = (
		Compose.context(),
		Compose.rectangle(),
		Compose.fill(colorant"sand")
	)
	# curve
	θ = π/12; points = Vector{Tuple}[]
	for y₀ ∈ 0.0:0.2:1.4
		x, y = (t -> t, t -> y₀ + 0.025 * sin(-5π*t))
		_points = [(x(t), y(t)) for t ∈ -0.5:0.01:1.5]
		x₀, y₀ = _points[1]
		# rotate
		for i ∈ eachindex(_points)
			x, y = _points[i]
			θ₀ = ϑ(x - x₀, y - y₀)
			if !isequal(θ₀, NaN)
				r = √((x - x₀)^2 + (y - y₀)^2)
				x, y = (x₀, y₀) .+ r .* (cos(θ + θ₀), -sin(θ + θ₀))
				_points[i] = (x, y)
			end
		end
		push!(points,_points)
	end
	polys = []; colors = range(colorant"rose", stop=
				   convert(typeof(colorant"rose"),
					   colorant"wine"), length=8) |> collect
	for _points in points
		poly = (
			Compose.context(),
			Compose.polygon([(-0.5, -0.5), _points..., (1.5, -0.5)]),
			Compose.fill(
				blend(colorant"rose",
					pop!(colors),
					mode=BlendScreen,
					opacity=0.65)
				),
			Compose.fillopacity(0.25 + 0.05rand([-1, 1]))
			)
		push!(polys, poly)
	end
	seal = (
		Compose.context(),
		Compose.rectangle(0.0, 0.8, 1.0, 0.2),
		Compose.fill(colorant"beige")
		)
	# image
	l = Line(points)
	layer = Layer(l)
	image = render([seal, layer, polys..., BG])
	image |> Compose.PDF("Leaf_001.pdf")
	image |> Compose.SVG("Leaf_001.svg")
end
