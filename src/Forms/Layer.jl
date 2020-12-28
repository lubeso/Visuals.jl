using Measures; import Compose

function render(layer::Tuple)

	Compose.compose(Compose.context(),layer)

end

function render(layers::Vector)

	Compose.compose(Compose.context(),layers...)

end
