class exports.ListComponent extends Framer.Layer

	@define "path",
		get: -> @_path
		set: (path) -> @_path = path

	@define "limit",
		default: undefined
		get: -> @_limit
		set: (val) -> @_limit = val

	@define "verticalSpacing",
		default: 0
		get: -> @_verticalSpacing
		set: (val) -> @_verticalSpacing = val

	@define "template",
		get: -> @_template
		set: (layer) ->
			if @path?
				child.destroy() for child in list.children
				@fetch()
			@_template = layer

	constructor: (options = {}) ->
		options.backgroundColor ?= ""
		super
		@fetch()

	fetch: ->

		Utils.domLoadJSON @path, (err, data) =>

			@props =
				frame: @template
				clip: false
				backgroundColor: ""
				parent: @template.parent

			@template.props =
				parent: this
				point: 0
				name: "#{@template.name}"

			for result, i in data.results

				unless i is 0

					break if i > @limit - 1

					copy = @template.copy()
					copy.props =
						name: "#{@template.name}#{i}"
						parent: @
						y: @height + @verticalSpacing
					@height = copy.maxY

					for child in copy.children
						val = @_search(result, child.name)
						val = @_search(result, child.text) unless val
						@_parse(val, child)

			for child in @template.children
				val = @_search(data.results[0], child.name)
				val = @_search(data.results[0], child.text) unless val
				@_parse(val, child)

			@emit("load")

	onLoad: (cb) -> @on("load", cb)

	_search: (object, string) ->

		return if string is undefined
		concats = string.split(" ")
		saveObject = object

		result = ""
		for concat in concats
			breadcrumbs = concat.split("_")
			object = saveObject
			for bc in breadcrumbs
				object = object[bc]
				result += " " unless result is ""
				result += "#{object}" if typeof object is "string"

		if typeof result is "string"
			return result
		else return undefined

	_parse: (value, layer) ->
		return unless value
		if value.match(/\.(jpeg|jpg|gif|png|svg)$/) isnt null
			layer.image = value
		else if Color.isColor(value)
			layer.backgroundColor = value
		else if typeof value is "string"
			layer.text = value
