include("Form.jl")
include("Layer.jl")
using NamedColors, Measures
import Compose, Cairo, Fontconfig
BACKGROUND = (Compose.context(), Compose.rectangle(), Compose.fill(colorant"wine"))

# form
# ---
mutable struct Arc <: Form

	class::Symbol

	params::Vector
	
	style::Vector

	Arc(class::Symbol, params::Vector; style=[]) = new(class, params, style)
end

# layer
# ---
function Layer(a::Arc)

	if a.class == :three_points

		form = three_points_arc(a.params...)

		layer = (Compose.context(),
			 form,
			 a.style...,
			 Compose.stroke(colorant"wine"),
			 Compose.linewidth(0.25mm))

	else

	end

	return layer

end

function three_points_arc(p₁, p₂, p₃)

	l₁₂ = ⟂(Line(midpoint(p₁, p₂), p₂))
	l₃₂ = ⟂(Line(midpoint(p₃, p₂), p₂))

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

# geometry
# ---

mutable struct Line

	p₁::Tuple

	p₂::Tuple

	m::Real

	Line(p₁, p₂; m=slope(p₁, p₂)) = new(p₁, p₂, m)

end

function ⟂(l::Line)

	p₁, p₂, m = (l.p₁, l.p₂, l.m)

	Δx, Δy = p₂ .- p₁; m′ = -1/m

	if abs(m′) == Inf

		p₂′ = p₁ .+ -sign(Δx) .* (0, Δx)

	else

		p₂′ = p₁ .+ (-Δy, m′ * Δx)

	end

	l′ = Line(p₁, p₂′, m=m′)

end

function intersection(p::Line, q::Line)

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

# example
# ---
begin
	bg, fg = rand(colors, 2)	
	BACKGROUND = (Compose.context(), Compose.rectangle(), Compose.fill(rand([colorant"Licorice", colorant"wine"])))
	Compose.set_default_graphic_size(508mm, 285.75mm)
	v = (0.0, 1.3); P = [(0.4, 1.6), (0.3, 0.1), (0.9, 0.25)]
	ps = [[p .+ √(+(((p .- v).^2)...)) .* (cos(θ), sin(θ)) for p ∈ P] for θ in 0:π/60:2π]
	str = rand([colorant"Vanilla", colorant"beige"])
	arcs = [Arc(:three_points, ps[i], style=[Compose.linewidth(.95mm), Compose.stroke(str)]) for i ∈ eachindex(ps)]
	layers = Layer.(arcs)
	img = render([layers..., BACKGROUND])
	img |> Compose.PDF("gallery/ARC_I.pdf")
end

