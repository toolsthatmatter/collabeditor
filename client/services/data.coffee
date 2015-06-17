angular.module('moedit.Services').factory 'moedit.Data', [ 
	'$rootScope'
	'$log'
	'$http'
	'$q'
	($rootScope, $log, $http, $q) ->

		self =
			documents: ->
				deferred = $q.defer()
				$http.get('/documents').then (response) ->
					deferred.resolve response.data
				deferred.promise
			
			document: (docid) ->
				deferred = $q.defer()
				$http.get("/documents/#{docid}").then (response) ->
					deferred.resolve response.data
				deferred.promise
			
			documentVersions: (docKey) ->
				deferred = $q.defer()
				# TODO: make this more smart
				@documents().then (documents) ->
					docsWithKey = _.filter documents, (d) -> d.key == docKey
					deferred.resolve docsWithKey
				deferred.promise

			getPreviousVersion: (document) ->
				deferred = $q.defer()
				@documentVersions(document.key).then (versions) ->
					previousVersion = document.version - 1 
					console.	log "pv: #{previousVersion}"
					if previousVersion < 0
						deferred.resolve null
					else
						previousVersionDocument = _.find versions, (d) -> d.version == previousVersion
						deferred.resolve previousVersionDocument
				deferred.promise

			getNextVersion: (document) ->
				deferred = $q.defer()
				@documentVersions(document.key).then (versions) ->
					nextVersion = document.version + 1
					console.log "nv: #{nextVersion}"
					nextVersionDocument = _.find versions, (d) -> d.version == nextVersion
					deferred.resolve nextVersionDocument
				deferred.promise

			hasPreviousVersion: (document) ->
				deferred = $q.defer()
				@getPreviousVersion(document).then (doc) ->
					deferred.resolve doc?
				deferred.promise

			hasNextVersion: (document) ->
				deferred = $q.defer()
				@getNextVersion(document).then (doc) ->
					deferred.resolve doc?
				deferred.promise

			saveDocument: (doc) ->
				if doc._id?
					$http.put "/documents/#{doc._id}", doc
				else
					$http.put "/documents/", doc

			deleteDocument: (doc) ->
				$http.delete "/documents/#{doc._id}"

		self
]