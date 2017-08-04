
exports.randomString = (strLen, chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") ->

	randomString = ""

	if Array.isArray(chars)
		for char in chars
			throw Error "Utils.randomString: '#{@}' is not a string." if typeof char isnt "string"

	else if typeof chars isnt "string"
		throw Error "Utils.randomString: '#{char}' is not a string." if typeof char isnt "string"

	for i in [0...strLen]
		randomString += chars[Math.floor(Utils.randomNumber(0, chars.length))]

	randomString if randomString
