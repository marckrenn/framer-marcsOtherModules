

Layer::animateOnSpline = (op = {}) ->

	# Calculate point on spline
	moveOnSpline = (p1, p2, p3, p4, t) ->
		p = {}
		a = modulatePoints(p1, p2, t)
		b = modulatePoints(p2, p3, t)
		c = modulatePoints(p3, p4, t)
		d = modulatePoints(a, b, t)
		e = modulatePoints(b, c, t)

		p.midX = modulatePoints(d, e, t).midX
		p.midY = modulatePoints(d, e, t).midY

		return p

	# Modulate between two points
	modulatePoints = (p1, p2, val) ->
		p = {}
		p.midX = Utils.modulate(val, [0,1], [p1.midX, p2.midX])
		p.midY = Utils.modulate(val, [0,1], [p1.midY, p2.midY])
		return p

	# Update Editor points
	updatePreview = =>

		# Update plotted Editor Spline
		for pp, i in pps
			point = moveOnSpline(op.points.start, op.points.controlPoint1, op.points.controlPoint2, op.points.end, val = 1 / pps.length * i)
			pp.midX = point.midX
			pp.midY = point.midY

		# Re-start animation after Editor change 
		unless op.modulate?
			_splineProxy.x = op.from

			_splineProxy.animate
				x: op.to
				options: op.animationOptions

		# Write Editor points to console
		points = {}

		points.start = {midX: op.points.start.midX, midY: op.points.start.midY} unless op.points.start.isLayer?
		points.controlPoint1 = {midX: op.points.controlPoint1.midX, midY: op.points.controlPoint1.midY} unless op.points.controlPoint1.isLayer?
		points.controlPoint2 = {midX: op.points.controlPoint2.midX, midY: op.points.controlPoint2.midY} unless op.points.controlPoint2.isLayer?
		points.end = {midX: op.points.end.midX, midY: op.points.end.midY} unless op.points.end.isLayer?
		console.log(points)


	# Vars & Defaults
	op.from = 0 unless op?.from?
	op.to = 1 unless op?.to?
	op.animationOptions = time: 1 unless op?.animationOptions?
	op.points = {} unless op?.points?
	op.editor = false unless op?.editor?
	op.points.start = this unless op.points.start?

	size = 15

	style =
		fontSize: "10px"
		fontWeight: "400"
		textAlign : "center"
		lineHeight: "15px"


	# Create Control- & Editor Points
	op.points.all = []

	unless op.points.start instanceof Layer

		midX = if op.points.start?.midX? then op.points.start.midX else @midX
		midY = if op.points.start?.midY? then op.points.start.midY else @midY

		op.points.start = new Layer
			parent: @parent
			size: size
			midX: midX
			midY: midY
			borderRadius: "50%"
			html: "S"
			name: "Spline Editor: start"
			style: style
			visible: op.editor

		op.points.start.draggable.enabled
		op.points.start.draggable.momentum = false

		op.points.all.push(op.points.start)

	else if op.points.start is this

		op.points.start = new Layer
			parent: @parent
			size: size
			midX: @midX
			midY: @midY
			borderRadius: "50%"
			backgroundColor: "rgba(0,0,0,.7)"
			html: "S"
			name: "Spline Editor: start"
			style: style
			visible: op.editor
			borderWidth: 1
			borderColor: "cyan"

		op.points.all.push(op.points.start)
		op.points.start.isLayer = true

	else op.points.start.isLayer = true


	unless op.points.controlPoint1 instanceof Layer

		midX = if op.points.controlPoint1?.midX? then op.points.controlPoint1.midX else @midX + 50
		midY = if op.points.controlPoint1?.midY? then op.points.controlPoint1.midY else @midY

		op.points.controlPoint1 = new Layer
			parent: @parent
			size: size
			midX: midX
			midY: midY
			borderRadius: "50%"
			html: "1"
			name: "Spline Editor: controlPoint1"
			style: style
			visible: op.editor

		op.points.controlPoint1.draggable.enabled
		op.points.controlPoint1.draggable.momentum = false

		op.points.all.push(op.points.controlPoint1)

	else op.points.controlPoint1.isLayer = true


	unless op.points.controlPoint2 instanceof Layer

		midX = if op.points.controlPoint2?.midX? then op.points.controlPoint2.midX else @midX
		midY = if op.points.controlPoint2?.midY? then op.points.controlPoint2.midY else @midY + 50

		op.points.controlPoint2 = new Layer
			parent: @parent
			size: size
			midX: midX
			midY: midY
			borderRadius: "50%"
			html: "2"
			name: "Spline Editor: controlPoint2"
			style: style
			visible: op.editor

		op.points.controlPoint2.draggable.enabled
		op.points.controlPoint2.draggable.momentum = false

		op.points.all.push(op.points.controlPoint2)

	else op.points.controlPoint2.isLayer = true


	unless op.points.end instanceof Layer

		midX = if op.points.end?.midX? then op.points.end.midX else @midX + 50
		midY = if op.points.end?.midY? then op.points.end.midY else @midY + 50

		op.points.end = new Layer
			parent: @parent
			size: size
			midX: midX
			midY: midY
			borderRadius: "50%"
			html: "E"
			name: "Spline Editor: end"
			style: style
			visible: op.editor

		op.points.end.draggable.enabled
		op.points.end.draggable.momentum = false

		op.points.all.push(op.points.end)

	else op.points.end.isLayer = true

	unless op.points.start is this
		op.points.start.onChange "point", -> updatePreview()
	op.points.controlPoint1.onChange "point", -> updatePreview()
	op.points.controlPoint2.onChange "point", -> updatePreview()
	op.points.end.onChange "point", -> updatePreview()


	unless op.editor
		p.name = "." for p in op.points.all

	# Create plotted Editor Spline
	if op.editor

		pps = []

		for i in [0 ... 100]
			pp = pps[i] = new Layer
				parent: @parent
				size: 2
				borderRadius: "50%"
				backgroundColor: "cyan" #"rgba(255,0,0,.5)"
				name: "."

		pp.bringToFront()

		op.points.start.bringToFront()
		op.points.controlPoint1.bringToFront()
		op.points.controlPoint2.bringToFront()
		op.points.end.bringToFront()


	# Animate on Spline
	unless op.modulate?

		_splineProxy = new Layer
			parent: this
			name: "."
			visible: false
	
		_splineProxy.animate
			x: op.to
			options: op.animationOptions

		_splineProxy.onChange "x", =>
			point = moveOnSpline(op.points.start, op.points.controlPoint1, op.points.controlPoint2, op.points.end, _splineProxy.x)
			@midX = point.midX
			@midY = point.midY

	else
			point = moveOnSpline(op.points.start, op.points.controlPoint1, op.points.controlPoint2, op.points.end, op.modulate)
			@midX = point.midX
			@midY = point.midY

	updatePreview() if op.editor
