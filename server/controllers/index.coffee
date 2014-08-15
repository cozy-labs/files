async = require 'async'
Client = require('request-json').JsonClient

CozyInstance = require '../models/cozy_instance'

module.exports.main = (req, res, next) ->
    async.parallel [
        (cb) -> CozyInstance.getLocale cb
        (cb) ->
            cb null, []
    ], (err, results) =>
        console.log 'hourra'
        console.log err
        console.log results

        if err then next err
        else
            [locale, tags] = results
            console.log locale
            console.log tags
            res.render 'index.jade', imports: """
                window.locale = "#{locale}";
                window.tags = "#{tags}".split(',');
            """
