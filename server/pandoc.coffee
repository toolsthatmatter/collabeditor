pdc  = require 'pdc'
fs   = require 'fs'
q    = require 'q'
path = require 'path'


Pandoc = class Pandoc
	test: () ->
		html = fs.readFileSync 'server/test.html'
		pdc html, 'html', 'docx', ['-o',  'blabla.docx', '--reference-docx', 'server/template/template.docx'],  (err, result) ->
			if err
				throw err;
			console.log result 

	createWord: (html, outname) ->
		deferred = q.defer()
		filename = path.join __dirname, 'docs', "#{outname}.docx"
		refdoc = path.join __dirname, 'template', "template.docx"
		pdc html, 'html', 'docx', ['-o',  filename, '--reference-docx', refdoc],  (err, result) ->
			if err
				deferred.reject err
			else
				deferred.resolve filename
		deferred.promise

	createPDF: (html, outname) ->
		deferred = q.defer()
		filename = path.join __dirname, 'docs', "#{outname}.pdf"
		pdc html, 'html', 'pdf', ['-t', 'latex', '-o',  filename],  (err, result) ->
			if err
				deferred.reject err
			else
				deferred.resolve filename
		deferred.promise

module.exports = Pandoc