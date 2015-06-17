fs     = require 'fs'
Pandoc = require './pandoc'
pandoc = new Pandoc
path   = require 'path'
q      = require 'q'

DocumentHandling = class DocumentHandling

	constructor: (@models) ->
		# read html header/footer
		@header = fs.readFileSync path.join(__dirname, 'template','header.html')
		@footer = fs.readFileSync path.join(__dirname, 'template','footer.html')
		#console.log "loaded header: #{@header}"
		#console.log "loaded footer: #{@footer}"

	createPreview: (docid) ->
		deferred = q.defer()
		@getDocument(docid).then (doc) =>
			h = @createHtml(doc)
			deferred.resolve h
		.catch (e) ->
			console.log e
		deferred.promise

	createWord: (docid) ->
		deferred = q.defer()
		@getDocument(docid).then (doc) =>
			html = @createHtml doc    
			pandoc.createWord(html, docid).then (outname) ->
				deferred.resolve outname
			.catch (e) ->
				console.log e
		.catch (e) ->
			console.log e
		deferred.promise
	
	createPDF: (docid) ->
		deferred = q.defer()
		@getDocument(docid).then (doc) =>
			html = @createHtml doc    
			pandoc.createPDF(html, docid).then (outname) ->
				deferred.resolve outname
			.catch (e) ->
				console.log e
		.catch (e) ->
			console.log e
		deferred.promise
	
	createHtml: (doc) ->
		html = @header
		html += "<h1>#{doc.title}</h1>\n\n"
		i = 1
		for chapter in doc.chapters
			html += "<h2>#{i++}. #{chapter.title}</h2>\n\n"
			html += "<p>#{chapter.content}</p>\n\n"
		html += @footer
		html
		
	getDocument: (docid) ->
		deferred = q.defer()
		@models.Document.findOne {_id: docid}, (err, doc) ->
			if err
				console.log "getDocument error: #{err}"
				deferred.reject err
			else
				console.log "getDocument success!"
				deferred.resolve doc
		deferred.promise

module.exports = DocumentHandling
