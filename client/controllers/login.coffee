controllers = angular.module('moedit.Controllers')
controllers.controller 'loginController', [
	'$scope'
	'$log'
	'$q'
	'$state'
	'moedit.Socket'
	'moedit.SweetAlert'
	'moedit.Focus'
	($scope, $log, $q, $state, Socket, SweetAlert, Focus) ->

		$scope.loading = false
		Focus.focus('#username')

		$scope.login = () ->
			$scope.loading = true
			$state.go 'edit'
]
