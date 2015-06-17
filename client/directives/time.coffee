app = angular.module('moedit.App')

app.directive "time", [  "$timeout",  "$filter",  ($timeout, $filter) ->
	return (scope, element, attrs) ->
		updateTime = ->
			element.text filter(time_string)

		updateLater = ->
			timeoutId = $timeout(->
				updateTime()
				updateLater()
			, intervalLength)

		timeoutId = null
		time_string = attrs.time
		intervalLength = 1000 * 10 # 10s
		filter = $filter("fromNow")
		element.bind "$destroy", ->
			$timeout.cancel timeoutId

		updateTime()
		updateLater()
]