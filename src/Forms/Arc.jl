include("Form.jl")
include("Layer.jl")
using Measures, NamedColors
import Compose, Cairo, Fontconfig

# geometry
# ---

mutable struct RefLine

	p₁::Tuple

	p₂::Tuple

	m::Real

	RefLine(p₁, p₂; m=slope(p₁, p₂)) = new(p₁, p₂, m)

end

function ⟂(l::RefLine)

	p₁, p₂, m = (l.p₁, l.p₂, l.m)

	Δx, Δy = p₂ .- p₁; m′ = -1/m

	if abs(m′) == Inf

		p₂′ = p₁ .+ -sign(Δx) .* (0, Δx)

	else

		p₂′ = p₁ .+ (-Δy, m′ * Δx)

	end

	l′ = RefLine(p₁, p₂′, m=m′)

end

function intersection(p::RefLine, q::RefLine)

	x₁, y₁ = p.p₁; m₁ = p.m
	x₂, y₂ = q.p₁; m₂ = q.m

	if abs(m₁) == Inf || abs(m₂) == Inf

		if abs(m₁) == abs(m₂)

			return missing

		elseif abs(m₁) == Inf

			x = x₁
			y = m₂ * (x - x₂) + y₂

		elseif abs(m₂) == Inf

			x = x₂
			y = m₁ * (x - x₁) + y₁

		end

		return (x, y)

	else

		if abs(m₁ - m₂) < 1e-8

			return missing

		else

			x = (m₁ * x₁ - m₂ * x₂ + y₂ - y₁)/(m₁ - m₂)
			y = m₁ * (x - x₁) + y₁

			return (x, y)

		end

	end

end

function slope(p₁, p₂)

	Δx, Δy = p₂ .- p₁

	if abs(Δx) < 1e-8

		m = Δy > 0 ? Inf : -Inf

	else

		m = Δy / Δx

	end

	return m

end

function midpoint(p₁, p₂)

	Δx, Δy = p₂ .- p₁

	x, y = p₁ .+ (Δx, Δy) ./ 2

	return x, y

end

function ϑ(Δx, Δy)

	if Δx >= 0 && Δy >= 0

		θ = atan(Δy / Δx)

	elseif Δx >= 0 && Δy < 0

		θ = 2π + atan(Δy / Δx)

	elseif Δx <= 0

		θ = π + atan(Δy / Δx)

	end

	return θ

end

# form
# ---
mutable struct Arc3Points <: Form

	points::Vector
	
	lw::Length
	style::Vector

	Arc3Points(points::Vector; lw=0.25mm, style=[]) = new(points, lw, style)
end

Layer(a::Arc3Points; config=Compose.context()) = Layer(a, config)

function three_points_arc(p₁, p₂, p₃)

	l₁₂ = ⟂(RefLine(midpoint(p₁, p₂), p₂))
	l₃₂ = ⟂(RefLine(midpoint(p₃, p₂), p₂))

	c = intersection(l₁₂, l₃₂)

	if c isa Missing

		return missing

	else

		x, y = c

	end

	r = √((x - p₂[1])^2 + (y - p₂[2])^2)

	A, B = [pᵢ .- c for pᵢ ∈ [p₁, p₃]]

	θ₁, θ₂ = [ϑ(A...), ϑ(B...)]

	if θ₁ > θ₂

		θ₁ -= 2π

	end

	points = [c .+ r .* (cos(θ), sin(θ)) for θ ∈ θ₁:π/99:θ₂]

	return Compose.line(points)

end

function Layer(a::Arc3Points, config::Compose.Context)

	form = three_points_arc(a.points...)

	layer = (
		config,
		form,
		a.style...,
		Compose.stroke(colorant"beige"),
		Compose.linewidth(0.25mm)
	)

	return layer

end

Layer(a::Arc3Points; config=Compose.context()) = Layer(a, config)

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm)
	BACKGROUND = (
		Compose.context(),
		Compose.rectangle(),
		Compose.fill(colorant"Licorice")
	)
	arrays = [[(0.5, 0.5), 
		   (0.5, 0.5) .+ 0.25 .* (cos(θ + π/4), sin(θ + π/4)), 
		   (0.5, 0.5) .+ 0.25 .* (cos(θ), sin(θ))] for 
		 θ ∈ 0.0:π/21:2π]
	arcs = Arc3Points.(arrays)
	layers = Layer.(arcs)
	image  = render([layers..., BACKGROUND])
	image  |> Compose.PDF("gallery/Arc3Points.pdf")
end

mutable struct ArcCPoints <: Form

	center::Tuple
	points::Vector

	lw::Length
	style::Vector

	ArcCPoints(center::Tuple, points::Vector; lw=0.25mm, style=[]) = new(center, points, lw, style)

end

function center_points_arc(c, p₁, p₂)

	x, y = c; x₁, y₁ = p₁

	r = √((x - x₁)^2 + (y - y₁)^2)

	A, B = [pᵢ .- c for pᵢ ∈ [p₁, p₂]]

	θ₁, θ₂ = [ϑ(A...), ϑ(B...)]

	if θ₁ > θ₂

		θ₁ -= 2π

	end

	points = [c .+ r .* (cos(θ), sin(θ)) for θ ∈ θ₁:π/99:θ₂]

	return Compose.line(points)

end

function Layer(a::ArcCPoints, config::Compose.Context)

	form = center_points_arc(a.center, a.points...)

	layer = (
		config,
		form,
		a.style...,
		Compose.stroke(colorant"beige"),
		Compose.linewidth(0.25mm)
	)

	return layer

end

Layer(a::ArcCPoints; config=Compose.context()) = Layer(a, config)

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm)
	BACKGROUND = (
		Compose.context(),
		Compose.rectangle(),
		Compose.fill(colorant"Licorice")
	)
	arrays = [
		  [(0.5, 0.65) .- (d/2, 0)
		   (0.5, 0.65) .+ (d/2, 0)] for d ∈ 0.1:0.05:0.6
	]
	centers = fill((0.5, 0.6), length(arrays))
	arcs = ArcCPoints.(centers, arrays)
	layers = Layer.(arcs)
	image  = render([layers..., BACKGROUND])
	image  |> Compose.PDF("gallery/ArcCPoints.pdf")
end

mutable struct ArcCAngles <: Form

	center::Tuple
	radius::Union{Real, Length}
	angles::Vector

	lw::Length
	style::Vector

	ArcCAngles(center::Tuple, radius::Union{Real, Length}, angles::Vector; lw=0.25mm, style=[]) = new(center, radius, angles, lw, style)

end

function Layer(a::ArcCAngles, config::Compose.Context)

	form = Compose.arc(
		a.center...,
		a.radius,
		a.angles...,
		false
	)

	layer = (
		config,
		form,
		a.style...,
		Compose.linewidth(a.lw),
		Compose.fill(nothing),
		Compose.stroke(colorant"beige")
	)

	return layer

end

Layer(a::ArcCAngles; config=Compose.context()) = Layer(a, config)

# example
# ---
begin
	Compose.set_default_graphic_size(5cm, 5cm)
	BACKGROUND = (
		Compose.context(),
		Compose.rectangle(),
		Compose.fill(colorant"Licorice")
	)
	arrays = [[θ, θ + 5π/4] for θ ∈ 0:π/6:2π]
	radii  = range(0.1, stop=0.4, length=length(arrays)) |> collect
	centers = fill((0.5, 0.5), length(arrays))
	arcs = ArcCAngles.(centers, radii, arrays)
	layers = Layer.(arcs)
	image  = render([layers..., BACKGROUND])
	image  |> Compose.PDF("gallery/ArcCAngles.pdf")
end

