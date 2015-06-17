# http://engineering.talis.com/articles/client-side-error-logging/
loggingModule = angular.module('moedit.Logging', [])

###*
# Service that gives us a nice Angular-esque wrapper around the
# stackTrace.js pintStackTrace() method. 
###
loggingModule.factory 'traceService', ->
	{ print: printStackTrace }

###*
# Override Angular's built in exception handler, and tell it to 
# use our new exceptionLoggingService which is defined below
###
loggingModule.provider '$exceptionHandler', $get: (exceptionLoggingService) ->
	exceptionLoggingService

###*
# Exception Logging Service, currently only used by the $exceptionHandler
# it preserves the default behaviour ( logging to the console) but 
# also posts the error server side after generating a stacktrace.
###
loggingModule.factory 'exceptionLoggingService', [
	'$log'
	'$window'
	'traceService'
	($log, $window, traceService) ->

		error = (exception, cause) ->
			# preserve the default behaviour which will log the error
			# to the console, and allow the application to continue running.
			$log.error.apply $log, arguments
			# now try to log the error to the server side.
			try
				errorMessage = exception.toString()
				# use our traceService to generate a stack trace
				stackTrace = traceService.print(e: exception)

				# TODO add meaningful data
				$.ajax
					type: 'POST'
					url: '/logger' 
					contentType: 'application/json'
					data: angular.toJson
						url: $window.location.href
						message: errorMessage
						type: 'exception'
						stackTrace: stackTrace
						cause: cause || ''

			catch loggingError
				$log.warn 'Error server-side logging failed'
				$log.log loggingError
			return

		error
]
