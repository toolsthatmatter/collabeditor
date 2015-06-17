_ = require 'lodash'
Chance = require 'chance'
chance = new Chance

module.exports = (models) ->

	save = (model, docsArray, cb) ->
		console.log "insert #{JSON.stringify(docsArray)}"
		model.collection.insert docsArray, (err, data) ->
			if err?
				console.log "error: #{err}"
			else
				docsArray = data
				console.dir docsArray
				cb()
			return

	models.Document.find {}, (err, doc) ->
		if doc? and !_.isEmpty doc
			console.log 'NOOOO FAKEDATA'
		else
			console.log 'CREATE FAKEDATA'
			authors = [chance.name(), chance.name(), chance.name()]
			comments = []
			chapters = []
			documents = []

			for j in [0..5]
				comments.push 
					author: _.sample authors
					key: chance.guid()
					text: _.sample ['super absatz', 'mist, nochmal', 'guck ich mir nochmal an']
					created: new Date()
			save models.Comment, comments, () ->
				for k in [0..10]
					aComment = _.sample comments
					someCommentedText = "<span id=\"#{aComment.key}\" class=\"comment\">#{chance.sentence()}</span>"
					chapters.push 
						author: _.sample authors
						number: "#{k}"
						title: chance.word()
						content: "#{chance.paragraph()} #{someCommentedText} #{chance.sentence()}"
						lastChanged: new Date()
						state: _.sample ['ONGOING', 'FINISHED']
						comments: aComment
						version: 1
				save models.Chapter, chapters, () ->
					for m in [0..3]
						d = 
							version: 0
							key: "#{chance.integer({min: 100000, max: 999999})}"
							headAuthor: _.sample authors
							title: chance.word()
							chapters: _.sample chapters, 5
							patient:
								name: chance.name()
								dob: chance.birthday()
							state: _.sample ['ONGOING', 'FINISHED']
						documents.push d
						# add another version
						dd = _.clone d, true
						dd.version++
						documents.push dd

					save models.Document, documents, () ->
						console.log "FINISHED INSERT FAKEDATA"
