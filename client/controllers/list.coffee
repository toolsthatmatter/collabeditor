controllers = angular.module('moedit.Controllers')
controllers.controller 'listController', [
	'$scope'
	'$log'
	'$q'
	'$state'
	'$window'
	'ngDialog'
	'messageCenterService'
	'moedit.Socket'
	'moedit.SweetAlert'
	'moedit.Focus'
	'moedit.Data'
	($scope, $log, $q, $state, $window, ngDialog, messageCenterService, Socket, SweetAlert, Focus, Data) ->

		$scope.newDocument = () ->
			dialog = ngDialog.open
				template: 'new-opinion-dialog'
				scope: $scope
			dialog.closePromise.then (dialogData) ->
				if dialogData.value?
					console.log "typ: #{dialogData.value}"
					Data.documents().then (documents) ->
						aDoc = _.first documents
						delete aDoc._id
						aDoc.key = "#{chance.integer({min: 100000, max: 999999})}"
						aDoc.title = chance.word()
						Data.saveDocument(aDoc).then (response) ->
							if response.status != 200
								messageCenterService.add('danger', "Fehler beim Speichern", {html: true});
							else
								messageCenterService.add('success', "Dokument <strong>#{document.title}</strong> erfolgreich angelegt", {timeout: 2000, html: true});
								getAllDocuments()

		$scope.deleteDocument = (document) ->
			console.log "delete document..."
			Data.deleteDocument(document).then (i) ->
				console.log "deleted document"
				messageCenterService.add('success', "Dokument <strong>#{document.title}</strong> erfolgreich gelöscht", {timeout: 2000, html: true});
				getAllDocuments()

		$scope.openDocument = (document) ->
			$state.go 'edit', {docid: document._id}

		$scope.docLastChangeDate = (document) ->
			_(document.chapters).max((c) -> moment(c.lastChanged)).value().lastChanged

		getAllDocuments = () ->
			Data.documents().then (documents) ->
				docsByKey = _.groupBy documents, 'key'
				docsByKeyArray = []
				for k, docs of docsByKey
					docsByKeyArray.push
						key: k
						firstDoc: _.first docs
						docs: docs
						selectedVersion: _.last(_.sortBy docs, 'version')
				$scope.docsByKey = docsByKeyArray

		getAllDocuments()
]
