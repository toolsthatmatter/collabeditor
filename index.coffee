path         = require 'path'
fs           = require 'fs'
express      = require 'express'
bodyParser   = require 'body-parser'
http         = require 'http'
serveStatic  = require 'serve-static' # use this because of mime type issues with express.static
socketio     = require 'socket.io'

# create web server instance
app     = express()

# TODO: do we need this?
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })

server  = http.Server app

# use own instance of mongoose for faking and stuff, couldnt get mers mongoose to work properly
m = require 'mongoose'
m.connect 'mongodb://localhost/moedit'
models = require('./server/models')(m)
fakeData = require './server/fakedata'
fakeData(models)


io = socketio(server) #create web socket for pushing data to clients
io.on 'connection', (socket) =>
	console.log "#{io.sockets.sockets.length} socket(s) connected"

port = process.env.NODEPORT || 3030
server.listen port, ->
	console.log "web server is listening on port #{port}"

# Set the public folder as static assets
app.use serveStatic path.join(__dirname, 'client', 'public')

# load routes
routes = require ('./server/routes')
routes(app, models, __dirname)
