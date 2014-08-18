americano = require 'americano'
fs = require 'fs'
path = require 'path'
localization = require './server/lib/localization_manager'

errorHandler = require './server/middlewares/errors'

start = (options, callback) ->

    options ?= {}
    options.name = 'Files'
    options.port = options.port
    options.host = process.env.HOST or "0.0.0.0"
    options.root = options.root or __dirname

    configPath = path.join process.cwd(), 'config.json'
    unless fs.existsSync configPath
        config = {}
        fs.writeFileSync configPath, JSON.stringify config

    localization.initialize ->
        americano.start options, (app, server) ->
            initialize = require './server/initialize'
            app.server = server
            app.use errorHandler
            initialize.afterStart app, server, callback

if not module.parent
    port = process.env.PORT or 9113
    start port: port, (err) ->

module.exports.start = start
