app = angular.module('moedit.App')
app.config ($provide) ->
	$provide.decorator 'taOptions', [
		'taRegisterTool'
		'$delegate'
		(taRegisterTool, taOptions) ->
			colors = ['red', 'yellow', 'blue', 'green', 'gray']
			console.log "================================="
			# $delegate is the taOptions we are decorating
			# register the tool with textAngular
			taRegisterTool 'addComment',
				buttontext: 'Kommentar'
				action: ->
					sel = document.getSelection().focusNode.data
					myScope = @.$parent.$parent
					newKey = chance.guid()
					myScope.commentRemoval = false
					@$editor().wrapSelection 'insertHTML', "<span id='#{newKey}' class='comment'>#{sel}</span>"
					myScope.commentRemoval = true
					console.log "wrapped: #{myScope.currentChapter.content}"
					myScope.newComment(myScope.currentChapter, newKey)
			# add the button to the default toolbar definition
			taOptions.toolbar[1].push 'addComment'
			taOptions
	]