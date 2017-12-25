class exports.Interval

	paused = false
	saveTime = saveFunction = null

	start: (time, f) ->
		saveTime = time
		saveFunction = f

		f()
		proxy = -> f() unless paused
		unless paused then @._id = timer = setInterval(proxy, time * 1000) else return

	pause:   -> paused = true
	resume:  -> paused = false
	reset:   -> clearInterval(@._id)
	restart: -> clearInterval(@._id); @.start(saveTime,saveFunction)