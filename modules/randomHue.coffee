
exports.randomHue = (baseColor = "hsla(201, 95, 57, 1)", range = [0,359.99]) ->

	if Array.isArray(baseColor)
		range = baseColor
		baseColor = "hsla(201, 95, 57, 1)"

	if Color.isColor(baseColor)
		bc = new Color(baseColor)
		new Color("hsla( #{Utils.randomNumber(bc.h + range[0], bc.h + range[1])} , #{bc.s*100}, #{bc.l*100}, #{bc.a})")

