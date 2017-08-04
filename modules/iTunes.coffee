

exports.iTunes = {

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
