controllers = angular.module('moedit.Controllers')
controllers.controller 'editController', [
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
	'messageCenterService'
	'ngDialog'
	($scope, $log, $q, $state, $stateParams, $window, Socket, SweetAlert, Focus, Data, messageCenterService, ngDialog) ->

		# autosave
		autoSaveCurrentDocument = () ->
			$log.debug "autosave"
			$scope.saveDocument($scope.currentDocument, "Automatisch gespeichert")
		
		autoSave = _.debounce autoSaveCurrentDocument, 5000
		$scope.commentRemoval = true

		$scope.selectChapter = (chapter) ->
			$log.info "select chapter #{chapter.title}:#{chapter.selected}"
			unhighlightAllComments()
			unselectComments()
			if $scope.chapterWatch?
				$scope.chapterWatch() # remove watch
			$scope.currentChapter = chapter
			for c in $scope.currentDocument.chapters
				if c._id == chapter._id
					c.selected = true
				else
					c.selected = false
			$scope.chapterWatch = $scope.$watch 'currentChapter.content', chapterchange, true
			Data.hasPreviousVersion($scope.currentDocument).then (hasOne) ->
				console.log "has pv: #{hasOne}"
				$scope.hasPreviousVersion = hasOne
			Data.hasNextVersion($scope.currentDocument).then (hasOne) ->
				console.log "has nv: #{hasOne}"
				$scope.hasNextVersion = hasOne

		$scope.selectComment = (comment) ->
			unhighlightComment($scope.currentComment)
			$log.info "select comment: #{comment.text}:#{comment.selected}:#{comment.key}"
			$scope.currentComment = comment
			for c in $scope.currentChapter.comments
				if c.key == comment.key
					c.selected = true
				else
					c.selected = false
			highlightComment($scope.currentComment)
			return true # this is because angular is complaing about: "Referencing a DOM node in Expression" when just returning something else

		unselectComments = () ->
			if $scope.currentChapter?.comments?
				for c in $scope.currentChapter.comments
					c.selected = false

		highlightComment = (comment) ->
			if comment?
				$("##{comment.key}").addClass('comment-highlight')

		unhighlightComment = (comment) ->
			if comment?
				$("##{comment.key}").removeClass('comment-highlight')

		unhighlightAllComments = () ->
			$(".comment").removeClass('comment-highlight')

		chapterchange = (newValue, oldValue) ->
			$log.debug "changed:: #{$scope.currentChapter.content}"
			if newValue != oldValue
				$scope.currentChapter.lastChanged = new Date()
				if $scope.commentRemoval
					removeMe = []
					for comment in $scope.currentChapter.comments
						idx = newValue.indexOf(comment.key)
						if idx < 0
							removeMe.push comment
							$log.debug "remove comment #{comment.text}"
					for r in removeMe
						_.remove($scope.currentChapter.comments, (c) -> c.key == r.key)
				autoSave()	

		$scope.newComment = (chapter, commentKey) ->
			dialog = ngDialog.open
				template: 'comment-input-dialog'
				scope: $scope
			dialog.closePromise.then (dialogData) ->
				console.log "key: #{commentKey}, text: #{dialogData.value}"
				comment = 
					author: chance.name()
					key: commentKey
					created: new Date()
					text: dialogData.value
				chapter.lastChanged = new Date()
				chapter.comments.push comment
				$scope.selectComment comment
				autoSave()

		$scope.newChapter = (document) ->
			document.chapters.push
				title: $scope.newChapterTitle
				author: chance.name()
				lastChanged: new Date()
				state: 'ONGOING'
				comments: []
				version: 1
			$scope.newChapterTitle = ''
			$scope.selectChapter(_.last document.chapters)
			autoSave()

		$scope.saveDocument = (document, msg = "Gutachten erfolgreich gespeichert") ->
			Data.saveDocument(document).then (response) ->
				if response.status != 200
					messageCenterService.add('danger', "Fehler beim Speichern", {html: true});
				else
					messageCenterService.add('success', msg, {timeout: 2000, html: true});

		$scope.docStateChanged = (val) ->
			console.log $scope.currentDocument.state

		$scope.deleteComment = (comment) ->
			unhighlightComment(comment)
			rgx = "<span id=\"#{comment.key}\" class=\".*?\">(.*?)<\/span>"
			console.log "rgx: #{rgx}"
			r = new RegExp rgx
			console.log "before: #{$scope.currentChapter.content}"
			m = $scope.currentChapter.content.match r
			if m[1]?
				$scope.currentChapter.content = $scope.currentChapter.content.replace r, m[1], 'g'
				console.log "after : #{$scope.currentChapter.content}"
				_.remove($scope.currentChapter.comments, (c) -> c.key == comment.key)
				autoSave()

		$scope.editComment = (comment) -> 
			$scope.newCommentText = comment.text
			dialog = ngDialog.open
				template: 'comment-input-dialog'
				scope: $scope
			dialog.closePromise.then (dialogData) ->
				console.log "key: #{comment.key}, text: #{dialogData.value}"
				#comment = _.find($scope.currentChapter.comments, (c) -> c.key == comment.key)
				comment.text = dialogData.value
				autoSave()

		$scope.newVersion = (document) ->
			newDoc = angular.copy document
			delete newDoc._id
			newDoc.version++
			$scope.saveDocument newDoc, "Neue Version gespeichert"

		$scope.previousVersion = () ->
			Data.getPreviousVersion($scope.currentDocument).then (document) ->
				$state.go 'edit', { docid: document._id }
		
		$scope.nextVersion = () ->
			Data.getNextVersion($scope.currentDocument).then (document) ->
				$state.go 'edit', { docid: document._id }

		$scope.diff = (document) ->
			$log.debug "goto diff of #{document.key}"
			$state.go 'diff' , {docKey: document.key, leftVersion: 0, rightVersion: document.version}

		# fix routing if someone comes here with no or non existing docid
		if $stateParams.docid
			Data.document($stateParams.docid).then (document) ->
				console.dir document
				$scope.currentDocument = document
				$scope.selectChapter($scope.currentDocument.chapters[0])
		else
			$state.go 'list'
]
