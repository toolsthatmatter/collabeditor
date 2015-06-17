controllers = angular.module('moedit.Controllers')
controllers.controller 'socketStatusController', ['$scope', 'moedit.Socket', '$log', ($scope, Socket, $log) ->
	Socket.on 'connect', (socket) ->
		$log.info "socket.io connected"
		$scope.socketIoConnected = true

	Socket.on 'disconnect', (socket) ->
		$log.warn "socket.io disconnected"
		$scope.socketIoConnected = false
]
