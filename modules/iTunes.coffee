

exports.iTunes = {

	_urlEncode: (url, keyValues) ->

		updateQueryString = (key, value, url) ->
			re = new RegExp("([?&])#{key}=.*?(&|#|$)(.*)", "gi")
			hash = undefined

			if re.test(url)

				if typeof value isnt "undefined" and value isnt null
					url.replace(re, "$1#{key}=#{value}$2$3")

				else
					hash = url.split("#")
					url = hash[0].replace(re, "$1$3").replace(/(&|\?)$/, "")
					url += "##{hash[1]}" if typeof hash[1] isnt "undefined" and hash[1] isnt null
					return url

			else

				if typeof value isnt "undefined" and value isnt null
					separator = if url.indexOf("?") isnt -1 then "&" else "?"
					hash = url.split("#")
					url = "#{hash[0]}#{separator}#{key}=#{value}"
					url += "##{hash[1]}" if typeof hash[1] isnt "undefined" and hash[1] isnt null
					return url

				else url

		string = newUrl = ""

		for key, value of keyValues

			newUrl = url if newUrl is ""
			string = newUrl = updateQueryString(key, value, newUrl)

		return string

	_queryItunes: (path, query, callback) ->

		urlEncodedQuery = _urlEncode("https://itunes.apple.com/#{path}", query)

		Utils.domLoadScript "https://code.jquery.com/jquery-3.2.1.min.js", ->

			$.ajax(
				url: urlEncodedQuery
				dataType: 'JSONP').done((data) ->
					try callback(data.results, data.resultCount, false)
		)		
		#).fail (data) ->
		#	console.log data

	search: (query, callback) -> @_queryItunes("search", query, callback)
	lookup: (query, callback) -> @_queryItunes("lookup", query, callback)

}
