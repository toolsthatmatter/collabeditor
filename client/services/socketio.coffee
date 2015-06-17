angular.module('moedit.Services').factory 'moedit.Socket', ['$rootScope', '$log', ($rootScope, $log) ->
		socket = io.connect()

		on: (eventName, callback) ->
			socket.on eventName, () ->
				args = arguments
				$rootScope.$apply () ->
					callback.apply(socket, args)
		emit: (eventName, data, callback) ->
			if typeof data == 'function'
				callback = data
				data = {}
			socket.emit eventName, data, () ->
				args = arguments
				$rootScope.$apply () ->
					if callback
						callback.apply(socket, args)
		emitAndListen: (eventName, data, callback) ->
			@.emit(eventName, data, callback)
			@.on(eventName, callback)
	]