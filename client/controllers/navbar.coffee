controllers = angular.module('moedit.Controllers')
controllers.controller 'navbarController', [
	'$rootScope'
	'$scope'
	'$log'
	'$state'
	($rootScope, $scope, $log, $state) ->
		
		$rootScope.fullscreen = false
		$rootScope.fullscreenText = 'Fullscreen an'

		$scope.toggleFullscreen = () ->
			$rootScope.fullscreen = !$rootScope.fullscreen
			$rootScope.fullscreenText = if $rootScope.fullscreen then 'Fullscreen aus' else 'Fullscreen an'
			$log.info "set fullscreen to #{$rootScope.fullscreen} with #{$rootScope.fullscreenText}"
]
