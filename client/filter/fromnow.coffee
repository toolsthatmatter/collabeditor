app = angular.module('moedit.App')

app.filter 'fromNow', () ->
  (time_string) ->
    moment(time_string).fromNow()

app.filter 'toDate', () ->
	(moment) ->
		moment.toDate()
