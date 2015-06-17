fs = require 'fs'
gulp = require 'gulp'
coffee = require 'gulp-coffee'
sourcemaps = require 'gulp-sourcemaps'
jade = require 'gulp-jade'
nodemon = require 'gulp-nodemon'
inject = require 'gulp-inject'
mainBowerFiles = require 'main-bower-files'
angularFilesort = require 'gulp-angular-filesort'
install = require 'gulp-install'
del = require 'del'
vinylPaths = require 'vinyl-paths'
stylus = require 'gulp-stylus'
zip = require 'gulp-zip'
util = require 'gulp-util'
mocha = require 'gulp-mocha'
uglify = require 'gulp-uglifyjs'
ignore = require 'gulp-ignore'

# config dirs
coffee_files = ['client/**/*.coffee', '!client/i18n/**/*.coffee', '!client/public/bower/**/*.coffee']
server_coffee_files = ['server/**/*.coffee', 'index.coffee']
jade_files = 'client/views/**/*.jade'
test_files = 'test/**/*.coffee'
stylus_files = 'client/styles/main.styl'
watch_stylus_files = 'client/styles/**/*.styl'
js_out_dir = './client/public/js/'
sourcemaps_out_dir = js_out_dir
server_js_out_dir = '.'
server_sourcemaps_out_dir = server_js_out_dir
css_out_dir = './client/public/css/'
html_out_dir = './client/public/'

# only client coffee files
gulp.task 'js', ->
	gulp.src coffee_files
		.pipe sourcemaps.init()
			.pipe coffee()
		.pipe sourcemaps.write() #{includeContent: false, sourceRoot: sourcemaps_out_dir} 
		.pipe gulp.dest js_out_dir

gulp.task 'jade', ->
	gulp.src jade_files
		.pipe jade({pretty: true})
		.pipe gulp.dest html_out_dir

gulp.task 'stylus', ->
	gulp.src stylus_files
		.pipe stylus()
		.pipe gulp.dest css_out_dir

gulp.task 'init', ->
	install()

# remove file that are created by gulp js/jade
gulp.task 'clean', ->
	gulp.src(["#{js_out_dir}**./*.js", "#{html_out_dir}**/*.html", "#{css_out_dir}**/*.css"], {read: false})
	.pipe vinylPaths(del)

# clean bower and node dirs, need to bower i and npm i after this
gulp.task 'clean_clean', ->
	gulp.src(['node_modules', './client/public/bower'], {read: false})
	.pipe vinylPaths(del)

gulp.task 'inject', ['js', 'stylus'], ->
	gulp.src './client/views/index.jade'
	# bower stuff
	.pipe inject(gulp.src(mainBowerFiles(), { read: false }), { ignorePath: 'client/public', name: 'bower'})
	# our own (mostly angular stuff)
	.pipe inject(gulp.src([
		'./client/public/js/**/*.js'
		'./client/public/vendor/**/*.js'
		'./client/public/css/**/*.css'
		], { read: false }), { ignorePath: 'client/public', name: 'own'}
	)
	# where to
	.pipe gulp.dest './client/views/'

gulp.task 'dev', ['inject', 'js', 'stylus', 'jade'], ->
	nodemon({script: 'index.coffee', ext: 'coffee styl jade'}) #ignore: ['./client/public/**/*', './**/*.js']
		.on 'change', ['js', 'stylus', 'jade']
		.on 'restart', ->
			console.log 'restarted!'

gulp.task 'watch', ->
	gulp.watch coffee_files, ['js']
	gulp.watch jade_files, ['jade']
	gulp.watch watch_stylus_files, ['stylus']

gulp.task 'test', ->
	gulp.src(test_files, {read: false})
		.pipe(mocha({reporter: 'dot'}))

# The default task (called when you run `gulp` from cli)
gulp.task 'default', ['dev']