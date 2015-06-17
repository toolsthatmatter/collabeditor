angular.module("moedit.Services").factory "moedit.Auth", [ 
	'$rootScope'
	'ipCookie'
	'$log'
	($rootScope, ipCookie, $log) ->

		self =
			login: (username, password) ->
				$log.debug "login user: #{username}, password: #{password}"
				authCookie = ipCookie cookieKey
				$log.debug "login user: auth cookie is #{JSON.stringify(authCookie)}"

				# ask server
				$log.debug "received login response: #{JSON.stringify(loginData)}"
				success = true # TODO
				if success
					$rootScope.user =
						name: username
						sessionToken: password # TODO: change this

					# set cookie
					ipCookie cookieKey, $rootScope.user, cookieOptions
					$rootScope.userLoggedIn = true

			logout: ->
				$rootScope.user = null
				$rootScope.userLoggedIn = false
				ipCookie.remove cookieKey

			isLoggedIn: ->
				authCookie = ipCookie cookieKey
				$log.info "isLoggedIn: auth cookie is #{JSON.stringify(authCookie)}"
				fake = false
				if fake
					@login "John Doe", "secret"
					$rootScope.userLoggedIn = true

				$log.info "isLoggedIn: $rootScope.userLoggedIn is #{$rootScope.userLoggedIn}"
				$rootScope.userLoggedIn

		self
]