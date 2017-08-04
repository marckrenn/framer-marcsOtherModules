

# 'Particle REST API Class'
# by Marc Krenn, July 12th, 2016 | marc.krenn@gmail.com | @marc_krenn



# Particle Class -----------------------------------


class exports.Particle extends Framer.BaseClass

	baseUrl = "https://api.particle.io/v1/devices"



	# Read-only properties ------------------------

	@.define "info",
		default: null
		get: -> @._info

	@.define "connectionStatus",
		default: "disconnected"
		get: -> @._connectionStatus

	@.define "isConnected",
		default: false
		get: -> @._isConnected

	@.define "postInterval",
		get: -> @._postInterval
		set: (val) ->
			@["postThrottled"] = _.throttle(postUnthrottled, val*1000)


	# Constructor / Init ---------------------------

	constructor: (@options={}) ->
		@.deviceId      = @.options.deviceId       ?= ""
		@.accessToken   = @.options.accessToken    ?= ""
		#@.getInterval   = @.options.getInterval    ?= if Utils.isChrome() then 1.5 else if Utils.isMobile() then 5 else 0
		@._postInterval = @.options.postInterval   ?= 0

		super @.options



	# `Post´ method ---------------------------

	postUnthrottled = (func, value, callback, deviceId, accessToken) =>

		url = "#{baseUrl}/#{deviceId}/#{func}?access_token=#{accessToken}"

		xhttp = new XMLHttpRequest

		xhttp.onreadystatechange = =>
			if xhttp.readyState is 4 and xhttp.status is 200 and callback isnt undefined
				#callback(JSON.parse(xhttp.response)) # callback is optional
				callback(JSON.parse(xhttp.response).return_value)

		xhttp.open 'POST', url, true
		xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
		xhttp.send("value=#{value}")


	post: (func, value, callback) =>
		@.postThrottled(func, value, callback, deviceId = @.deviceId, accessToken = @.accessToken)


	# Synonyms:

	turn: (func, value, callback) ->
		@.post(func, value, callback)

	set: (func, value, callback) ->
		@.post(func, value, callback)

	write: (func, value, callback) ->
		@.post(func, value, callback)



	# `Get´ method ----------------------------

	get: (variable, callback) ->

		Utils.domLoadJSON "#{baseUrl}/#{@.deviceId}/#{variable}?access_token=#{@.accessToken}", (error, data) ->
			callback(data.result) if data?

	# Synonyms:

	fetch: (variable, callback) ->
		@.get(variable, callback)

	query: (variable, callback) ->
		@.get(variable, callback)

	read: (variable, callback) ->
		@.get(variable, callback)



	# `Monitor´ method -------------------------

	onChange: (func, callback) ->

		if func is "connection"
			
			saveConnected = undefined


			do connectionUpdate = =>

				Utils.domLoadJSON "#{baseUrl}/#{@.deviceId}/?access_token=#{@.accessToken}", (error, data) =>

					if data?

						if data.connected
							@._isConnected = true
							@._connectionStatus = "connected"
						else
							@._isConnected = false
							@._connectionStatus = "disconnected"

						# Add returned parameters as propterties to the object
						@[property[0]] = property[1] for property in _.zip(Object.keys(data),_.map(data))

						@._info = data
						callback(data) if data.connected isnt saveConnected
						saveConnected = data.connected

					else
						@._isConnected = false
						@._connectionStatus = "noInternetConnection"
						callback(false) #if saveConnected isnt false
						saveConnected = false



			#connectionUpdate()

			Utils.interval 2, => connectionUpdate()


		else

			url = "https://api.particle.io/v1/devices/events?access_token=#{@.accessToken}"
			source = new EventSource(url)
			#console.log "Firebase: Listening to changes made to '#{path}' \n URL: '#{url}'" if @debug

			source.addEventListener func, (ev) ->
				callback(JSON.parse(ev.data).data)
