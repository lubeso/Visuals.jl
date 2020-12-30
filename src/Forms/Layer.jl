using Measures; import Compose

function render(layer::Tuple, config::Compose.Context)

	Compose.compose(config,layer)

end
render(layer::Tuple; config=Compose.context()) = render(layer, config)

function render(layers::Vector, config::Compose.Context)

	Compose.compose(config,layers...)

end
render(layers::Vector; config=Compose.context()) = render(layers, config)