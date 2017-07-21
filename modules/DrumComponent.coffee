
class exports.DrumComponent extends Framer.BaseClass

	constructor: (@options={}) ->
		@options.segments ?= null
		@options.fadeDepth ?= null
		@options.verticalPadding ?= null
		@options.radius ?= null
		@options.startIndex ?= 0
		@options.midX ?= 0
		@options.midY ?= 0
		@options.midZ ?= 0

		super

		unless @options.verticalPadding
			if @options.segments?
				@options.verticalPadding = @options.segments[0].height

		d = @options.segments.length / Math.PI / 2
		l = @options.segments.length
		h = @options.verticalPadding

		unless @options.radius
			@options.radius = (l * h - h / l * Math.PI) / Math.PI

		allPosZ = []

		for layer, i in @options.segments

			posZ = allPosZ[i] = @options.midZ + (@options.radius / 2) * Math.cos((i + @options.startIndex) / d)

			layer.props =
				midX: @options.midX
				midY: @options.midY + (@options.radius / 2) * Math.sin((i + @options.startIndex) / d)
				z: posZ
				rotationX: (360 / l) * (i + @options.startIndex) * -1

		maxDepth = Math.max.apply @, allPosZ
		@options.fadeDepth = maxDepth unless @options.fadeDepth

		for layer, i in @options.segments
			layer.opacity = Utils.modulate(layer.z, [maxDepth, maxDepth - @options.fadeDepth], [1, 0], true)



		@content = new Layer
			size: 0
			visible: false
			name: ".content"

		@content.onChange "y", =>

			for layer, i in @options.segments

				layer.props =
					midX: @options.midX
					midY: @options.midY + (@options.radius / 2) * Math.sin((i + @options.startIndex + @content.y) / d)
					z: @options.midZ + (@options.radius / 2) * Math.cos((i + @options.startIndex + @content.y) / d)
					rotationX: (360 / l) * (i + @options.startIndex + @content.y) * -1
					opacity: Utils.modulate(layer.z, [maxDepth, maxDepth - @options.fadeDepth], [1, 0], true)
