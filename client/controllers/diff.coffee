controllers = angular.module('moedit.Controllers')
controllers.controller 'diffController', [
	'$scope'
	'$log'
	'$q'
	'$state'
	'$stateParams'
	'$window'
	'moedit.Socket'
	'moedit.SweetAlert'
	'moedit.Focus'
	'moedit.Data'
	($scope, $log, $q, $state, $stateParams, $window, Socket, SweetAlert, Focus, Data) ->

		$scope.cleanContent = (s) ->
			S(s).stripTags().s


		# fix routing if someone comes here with no or non existing docid
		if $stateParams.docKey?
			$log.debug "show documents #{$stateParams.docKey}, leftVersion: #{$stateParams.leftVersion}, rightVersion: #{$stateParams.rightVersion}"
			Data.documentVersions($stateParams.docKey).then (documents) ->
				console.dir documents
				lv = parseInt $stateParams.leftVersion
				rv = parseInt $stateParams.rightVersion
				$scope.leftVersionDocument = _.find documents, (d) -> d.version == lv
				$scope.rightVersionDocument = _.find documents, (d) -> d.version == rv
				$scope.left = $scope.cleanContent $scope.leftVersionDocument
				$scope.right = $scope.cleanContent $scope.rightVersionDocument
		else
			$state.go 'list'
]