app = angular.module('moedit.App')

# routes
app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', ($stateProvider, $urlRouterProvider, $locationProvider) ->

	$stateProvider
		.state 'login',
			url: "/login"
			templateUrl: 'partials/login.html'
			controller: 'loginController'
		
		.state 'logout',
			url: "/logout"

		.state 'edit',
			url: "/edit/:docid"
			templateUrl: 'partials/edit.html'
			controller: 'editController'

		.state 'list',
			url: "/list"
			templateUrl: 'partials/list.html'
			controller: 'listController'

		.state 'diff',
			url: "/diff/:docKey/:leftVersion/:rightVersion"
			templateUrl: 'partials/diff.html'
			controller: 'diffController'


	$urlRouterProvider.otherwise('/list');

	$locationProvider.html5Mode(true)
]

# take not logged in user to login
app.run ['$rootScope', '$state', '$log', 'moedit.Auth', ($rootScope, $state, $log, Auth) ->
	$rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
		$rootScope.showFullscreen = toState.name == 'edit'
		$log.info "statechange from: #{fromState.name} to: #{toState.name}, showFullscreen: #{$rootScope.showFullscreen}"
		return
		if toState.name != 'login'
			if !Auth.isLoggedIn()
				$log.info "not logged in for that state. goto login."
				event.preventDefault()
				$state.go 'login'

			if toState.name == 'logout'
				$log.info "logout and goto login"
				Auth.logout()
				event.preventDefault()
				$state.go 'login'
]