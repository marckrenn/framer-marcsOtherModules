# Buggy and unfinished garbage code:

class HologramComponent extends Layer

	savePos = {rotationX: 0, rotationY: 0}

	@define "force2d",
		get: -> false,
		set: (val) -> console.warn("HologramComponent cannot be force2D'ed, for obvious reason") if val

	@define "clip",
		get: -> false,
		set: (val) -> console.warn("HologramComponent cannot be clipped") if val

	smoothingDefault = {time: .1, curve: "ease"}
	@define "smoothing",
		default: smoothingDefault,
		get: -> @_smoothing
		set: (val) ->
			def = smoothingDefault
			@_smoothing = _.extend(def, val)

	@define "content",
		get: -> @selectChild("content")

	@define "_proxy",
		get: -> @selectChild(".proxy")

	@define "currentAccel",
		default: {x: 0, y: 0},
		get: -> @_currentAccel,
		set: (val) -> @_currentAccel = val

	@define "previousAccel",
		default: {x: 0, y: 0},
		get: -> @_previousAccel,
		set: (val) -> @_previousAccel = val

	@define "sensitivity",
		default: 1,
		get: -> @_sensitivity,
		set: (val) -> @_sensitivity = val

	clampDefault = {down: -Infinity, up: Infinity, left: -Infinity, right: Infinity}
	@define "clamp",
		default: clampDefault,
		get: -> @_clamp,
		set: (val) ->
			def = clampDefault
			@_clamp = _.extend(def, val)

	debugDefault = {enabled: !Utils.isMobile(), sensitivity: 1, animationOptions: {time: 1, curve: Spring(damping: 1)}}
	@define "debug",
		default: debugDefault
		get: -> @_debug,
		set: (val) ->
			def = debugDefault
			@_debug = _.extend(def, val)

			@onPan (ev) ->
				if @_debug.enabled
					if ev.shiftKey
						@_simulate = false
						@animateStop()
						@rotationX = -ev.offset.y / (@_debug.sensitivity * 10)
						@rotationY = ev.offset.x / (@_debug.sensitivity * 10)

			@onPanEnd ->
				if @_debug.enabled
					@animate
						rotationX: savePos.rotationX
						rotationY: savePos.rotationY
						options: @debug.animationOptions
					@onAnimationEnd => @_simulate = true

	autoRecenterDefault = {enabled: true, after: 2, _counter: 0, threshold: .3, throttle: 0, animationOptions: {time: 1, curve: Spring(damping: 1)}}
	@define "autoRecenter",
		default: autoRecenterDefault
		get: -> @_autoRecenter,
		set: (val) ->
			def = autoRecenterDefault
			@_autoRecenter = _.extend(def, val)


	constructor: (@options = {}) ->
		bg = @options.backgroundColor ?= ""
		w = @options.width ?= Screen.width
		h = @options.height ?= Screen.height
		s = @options.size
		super

		@props =
			backgroundColor: bg
			width: w
			height: h
			size: s

		content = new Layer
			parent: this
			size: @size
			backgroundColor: ""
			name: "content"

		_proxy = new Layer
			parent: this
			visible: false
			name: ".proxy"

		autoRecenter = Utils.throttle @autoRecenter.throttle, =>
			@_proxy.animate
				x: @currentAccel.x
				y: @currentAccel.y
				options: @autoRecenter.animationOptions
			@emit("autoRecentered")

		initCentering = _.once => @_proxy.point = @currentAccel


		window.addEventListener "devicemotion", (event) =>

			@emit("motion")
			@_currentAccel = {}
			@currentAccel.x = event.accelerationIncludingGravity.x
			@currentAccel.y = event.accelerationIncludingGravity.y

			initCentering(@currentAccel)

			delta = Math.max.apply @, [Math.abs(@currentAccel.x - @previousAccel.x), Math.abs(@currentAccel.y - @previousAccel.y)]

			if @autoRecenter.enabled
				if delta < @autoRecenter.threshold
					@autoRecenter._counter++
					@emit("steady")
				else
					@autoRecenter._counter = 0
					@emit("autoRecenterReset")

				if @autoRecenter._counter >= (@autoRecenter.after * 60)
					autoRecenter()
					@autoRecenter._counter = 0
					@emit("autoRecenterReset")

			@animate
				rotationY: Utils.clamp((@currentAccel.x - @_proxy.x) * @sensitivity, @clamp.left, @clamp.right)
				rotationX: Utils.clamp((@currentAccel.y - @_proxy.y) * @sensitivity, @clamp.up, @clamp.down)
				options: @smoothing

			@previousAccel = @currentAccel


	onRecentered: (cb) -> @on("recentered", cb)
	onSteady: (cb) -> @on("steady", cb)
	onAutoRecenterReset: (cb) -> @on("autoRecenterReset", cb)
	onAutoRecentered: (cb) -> @on("autoRecentered", cb)
	onMotion: (cb) -> @on("motion", cb)

	recenter: (animationOptions = {time: 1, curve: Spring(damping: 1)}) ->
		@_proxy.animateStop()
		@_proxy.animate
			x: @currentAccel.x
			y: @currentAccel.y
			options: animationOptions
		@emit("recentered")

	simulationStart: (simsensitivity = 1, simSpeed = 1) =>
		counter = 0
		@_simulate = true
		Framer.Loop.on "render", =>
			if @_simulate

				@rotationX = Math.sin(counter) * simsensitivity
				@rotationY = Math.cos(counter) * -simsensitivity
				#@z = Math.cos(counter) * -simsensitivity
				#@perspective = (Utils.modulate(Math.sin(counter), [-1,1], [0,1]) * simsensitivity) * 500 + 1000
				counter += simSpeed / 60
				savePos = {rotationX: @rotationX, rotationY: @rotationY}

	simulationEnd: (animationOptions = {time: .5, curve: Spring(damping: 1)})->
		@_simulate = false
		@recenter()
		@animate
			rotationX: 0
			rotationY: 0
			options: animationOptions


exports.wrap = (options) ->

	layer = options.layer ?= options
	Screen.backgroundColor = options.backgroundColor ?= layer.backgroundColor
	Screen.gradient = options.Gradient ?= layer.gradient
	layer.backgroundColor = ""
	layer.gradient = null

	defaultProps = {frame: layer.frame, backgroundColor: "", image: "", name: layer.name}

	_tempHolo = new HologramComponent
	_tempHolo.props = @_clamp = _.extend(options, defaultProps)

	for child in layer.children
		child.parent = _tempHolo.content

	layer.destroy()
	return _tempHolo
