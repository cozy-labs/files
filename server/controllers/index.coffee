async = require 'async'
cozydb = require 'cozydb'

module.exports.main = (req, res, next) ->
    async.parallel [
<<<<<<< HEAD
        (cb) -> CozyInstance.getLocale cb
        (cb) ->
            cb null, []
=======
        (cb) -> cozydb.api.getCozyLocale cb
        (cb) -> cozydb.api.getCozyTags cb
        (cb) -> cozydb.api.getCozyInstance cb
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
    ], (err, results) =>
        console.log 'hourra'
        console.log err
        console.log results

        if err then next err
        else
<<<<<<< HEAD
            [locale, tags] = results
            console.log locale
            console.log tags
            res.render 'index.jade', imports: """
                window.locale = "#{locale}";
                window.tags = "#{tags}".split(',');
=======
            [locale, tags, instance] = results
            if instance?.domain? and instance.domain isnt 'domain.not.set'
                # Parse domain
                domain = instance.domain
                if domain.indexOf('https') is -1
                    domain = "https://#{domain}"
                if domain.slice('-1') is "/"
                    domain = domain.substring 0, domain.length-1
                domain = domain + "/public/files/"
            else
                domain = false
            res.render "index", imports: """
                window.locale = "#{locale}";
                window.tags = "#{tags.join(',').replace('\"', '')}".split(',');
                window.domain = "#{domain}";
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
            """
