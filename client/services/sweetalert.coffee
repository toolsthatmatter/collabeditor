angular.module("moedit.Services").factory "moedit.SweetAlert", [ '$timeout', '$window', ($timeout, $window) ->
		swal = $window.swal
		
		#public methods
		self =
			swal: (arg1, arg2, arg3) ->
				$timeout (->
					if typeof (arg2) is "function"
						swal arg1, ((isConfirm) ->
							$timeout ->
								arg2 isConfirm
						), arg3
					else
						swal arg1, arg2, arg3
				), 200

			adv: (object) ->
				$timeout (->
					swal object
				), 200

			timed: (title, message, type, time) ->
				$timeout (->
					swal
						title: title
						text: message
						type: type
						timer: time
				), 200

			success: (title, message) ->
				$timeout (->
					swal title, message, "success"
				), 200

			error: (title, message) ->
				$timeout (->
					swal title, message, "error"
				), 200

			warning: (title, message) ->
				$timeout (->
					swal title, message, "warning"
				), 200

			info: (title, message) ->
				$timeout (->
					swal title, message, "info"
				), 200
		self
]