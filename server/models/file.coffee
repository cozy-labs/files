fs = require 'fs'
americano = require 'americano-cozy-pouchdb'
moment = require 'moment'
feed = require '../lib/feed'
log = require('printit')
    prefix: 'file-model'

Folder = require './folder'
Binary = require './binary'
CozyInstance = require './cozy_instance'


module.exports = File = americano.getModel 'File',
    path: String
    name: String
    docType: String
    mime: String
    creationDate: String
    lastModification: String
    class: String
    size: Number
    binary: Object
    modificationHistory: Object
    clearance: (x) -> x
    tags: (x) -> x

File.all = (params, callback) ->
    File.request "all", params, callback

File.byFolder = (params, callback) ->
    File.request "byFolder", params, callback

File.byFullPath = (params, callback) ->
    File.request "byFullPath", params, callback


# Perform all operation required to create a new file:
# * Create document.
# * Create a binary Document and attach file to it.
# * Index file name for better search
# * Remove temporary created file.
File.createNewFile = (data, file, callback) =>
    upload = true
    attachBinary = (newFile) ->

        # Here file is a stream. For some weird reason, request-json requires
        # that a path field should be set before uploading.
        file.path = data.name
        newFile.attachBinary file, {"name": "file"}, (err, res, body) ->
            upload = false
            if err
                newFile.destroy (error) ->
                    callback "Error attaching binary: #{err}"
            else
                index newFile

    # Index file name to Cozy indexer to allow quick search on it.
    index = (newFile) ->
        newFile.index ["name"], (err) ->
            console.log err if err
            callback null, newFile

    # This action is required to ensure that the application is not stopped by
    # the "autostop" feature of the controller. It could occurs if the file is
    # too long to upload. The controller could think that the application is
    # unactive.
    keepAlive = () =>
        if upload
            feed.publish 'usage.application', 'files'
            setTimeout () =>
                keepAlive()
            , 60*1000

    # Create file document then attach file stream as binary to that file
    # document.
    File.create data, (err, newFile) =>
        if err
            callback new Error "Server error while creating file; #{err}"
        else
            attachBinary newFile
            keepAlive()

File::getFullPath = ->
    @path + '/' + @name

File::getPublicURL = (cb) ->
    CozyInstance.getURL (err, domain) =>
        return cb err if err
        url = "#{domain}public/files/files/#{@id}/attach/#{@name}"
        cb null, url

File::getParents = (callback) ->
    Folder.all (err, folders) =>
        return callback err if err

        # only look at parents
        fullPath = @getFullPath()
        parents = folders.filter (tested) ->
            fullPath.indexOf(tested.getFullPath()) is 0

        # sort them in path order
        parents.sort (a,b) ->
            a.getFullPath().length - b.getFullPath().length

        callback null, parents

File::updateParentModifDate = (callback) ->
    Folder.byFullPath key: @path, (err, parents) =>
        if err
            callback err
        else if parents.length > 0
            parent = parents[0]
            parent.lastModification = moment().toISOString()
            parent.save callback
        else
            callback()

File::destroyWithBinary = (callback) ->
    if @binary?
        binary = new Binary @binary.file
        binary.destroy (err) =>
            if err
                log.error "Cannot destroy binary linked to document #{@id}"
            @destroy callback
    else
        @destroy callback

if process.env.NODE_ENV is 'test'
    File::index = (fields, callback) -> callback null
    File::search =  (query, callback) -> callback null, []
