
ScrollComponent::enableMouseWheelPlus = (o = {}) ->

	# Framer auto-refresh compatible EventListener
	addEventListener = (event, callback) ->
		Framer.CurrentContext.domEventManager.wrap(window).addEventListener event, (ev) =>
			ev.preventDefault()
			callback(ev)

	# Apply defaults if necessary
	step = o.step ?= "velocity"
	scrollAxis = o.scrollAxis ?= "y"
	physicalScrollAxis = o.physicalScrollAxis ?= scrollAxis
	overscroll = o.overscroll ?= false
	throttle = o.throttle ?= 0
	threshold = o.threshold ?= 0
	requiresMouseOver = o.requiresMouseOver ?= true

	snap = o.snap ?= {}
	snap.every = o.snap.every ?= 1
	snap.offset = o.snap.offset ?= 0

	options = o.options ?= {}
	options.instant = o.options.instant ?= true unless o.options.time

	shouldScroll = !requiresMouseOver
	thresholdCounter = 0

	if requiresMouseOver
		@onMouseOver -> shouldScroll = true
		@onMouseOut -> shouldScroll = false


	scroll = Utils.throttle throttle, (event) =>
		thresholdCounter = 0

		switch physicalScrollAxis
			when "x" then delta = event.wheelDeltaX
			when "y" then delta = event.wheelDeltaY
			when "auto"
				delta = if Math.abs(event.wheelDeltaY) > Math.abs(event.wheelDeltaX) then event.wheelDeltaY else event.wheelDeltaX

		direction = if delta < 0 then -1 else if delta > 0 then 1 else null
		return if direction is null

		if step is "velocity" then velocity = Math.abs(event.wheelDeltaY) else velocity = step

		target = @content[scrollAxis] + (velocity * direction)
		target = Math.round(target / snap.every) * snap.every - snap.offset

		unless overscroll
			switch scrollAxis
				when "x" then target = Utils.clamp(target, 0, -@content.width + @width)
				when "y" then target = Utils.clamp(target, 0, -@content.height + @height)

		@content.animate("#{scrollAxis}": target, options: options)

		# Emit events
		@emit(Events.ScrollStart, event)
		@emit(Events.ScrollAnimationDidStart, event)
		@emit(Events.Scroll, event)
		@emit(Events.ScrollEnd, event) if options.instant
		@onAnimationEnd =>
			@emit(Events.ScrollEnd, event)
			@emit(Events.ScrollAnimationDidEnd, event)

	addEventListener "wheel", (event) ->
		thresholdCounter += Math.abs(event.wheelDeltaY)
		scroll(event) if thresholdCounter >= threshold and shouldScroll
