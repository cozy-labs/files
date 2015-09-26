<<<<<<< HEAD
americano = require 'americano-cozy-pouchdb'

module.exports = User = americano.getModel 'User',
    email: String
    password: String
    salt: String
    public_name: String
    timezone: String
    owner: Boolean
    activated: Boolean

User.first = (callback) ->
    User.request 'all', (err, users) ->
        if err? then callback new Error err
        else if not users or users.length is 0 then callback null, null
        else  callback null, users[0]

User.getDisplayName = (callback) ->
    User.first (err, user) ->
        if user?
            # display name management
            if user.public_name?.length > 0 then name = user.public_name
            else
                name = hideEmail user.email
                words = name.split ' '
                name = words.map((word) ->
                    return word.charAt(0).toUpperCase() + word.slice 1
                ).join ' '
            callback null, name
        else
            callback null, null
=======
cozydb = require 'cozydb'

>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

hideEmail = (email) ->
    email.split('@')[0]
        .replace '.', ' '
        .replace '-', ' '
<<<<<<< HEAD
=======


# Get User Information
#
# This method get current cozy user from the CozyDB API and return a filtered
# object containing the user name and email.
#
# @returns obj
#   name: string
#   email: string
#
getUserInfo = (callback) ->
    cozydb.api.getCozyUser (err, user) ->
        return callback err if err

        name = if user.public_name?.length
            user.public_name
        else
            words = hideEmail(user.email).split ' '
            words.map((word) -> word[0].toUpperCase() + word[1...]).join ' '

        callback null,
            name:  name
            email: user.email

module.exports.getUserInfo = getUserInfo


# Get Display Name
#
# This method is just a convenient wrapper around getUserInfo method that
# execute the given callback on the user.name only.
module.exports.getDisplayName = (callback) ->
    getUserInfo (err, user) ->
        return callback err if err
        callback null, user.name
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
