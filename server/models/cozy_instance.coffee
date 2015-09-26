americano = require 'cozy-db-pouchdb'
path = require 'path'
log = require('printit')
    prefix: 'Files'


module.exports = CozyInstance = {}

CozyInstance.first = (callback) ->
    configPath = path.join process.cwd(), 'config'

    try
        instance = require configPath
    catch
        console.log err
        log.error 'No config file found at ' + configPath
        instance = {}
    instance.domain ?= 'default.domain.com'
    instance.locale ?= 'en'
    callback null, instance

CozyInstance.getURL = (callback) ->
    CozyInstance.first (err, instance) ->
        callback null, instance.domain

CozyInstance.getLocale = (callback) ->
    CozyInstance.first (err, instance) ->
        callback null, instance.locale
