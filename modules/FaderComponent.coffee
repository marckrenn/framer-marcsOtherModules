class exports.FaderComponent extends Framer.Layer

	@define "images",
		default: @image
		get: -> @_images
		set: (images) ->

			if @imageLayers
				layer.destroy() for layer in @imageLayers
			else @imageLayers = []

			for image, i in images
				imageLayer = @imageLayers[i] = new Layer
					parent: this
					name: ".image#{i}"
					image: image
					backgroundColor: ""
					size: @size
					opacity: 0

			@_images = images

	@define "currentImage",
		default: 0
		get: -> @_currentImage
		set: (img) ->
			img = Utils.clamp(img, 0, @imageLayers.length - 1)
			imgA = Math.floor(img)
			imgB = Math.ceil(img)
			imageLayer.opacity = 0 for imageLayer in @imageLayers
			@imageLayers[imgA].opacity = 1
			@imageLayers[imgB].opacity = 1 - Math.abs((imgB - img) % 1)
			@_currentImage = img
			@emit("change:currentImage")

	constructor: (options = {}) ->
		options.clip ?= true
		super

		@onChange "size", =>
			for imageLayer in @imageLayers
				imageLayer.size = @size

	onFade: (cb) -> @on("change:currentImage", cb)
