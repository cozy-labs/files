fs = require 'fs'
path = require 'path'
should = require('chai').should()
americano = require 'americano'
moment = require 'moment'
rimraf = require 'rimraf'
Decompress = require 'decompress'

helpers = require './helpers'
client = helpers.getClient()

describe "Folders management", ->

    before helpers.startApp
    before helpers.cleanDB
    after helpers.stopApp
    before helpers.cleanDB

    describe "Create folder", ->

        describe "Create a new folder", ->
            it "When I send a request to create a folder", (done) ->
                folder =
                    name: "root"
                    path: ""
                client.post "folders/", folder, (err, res, body) =>
                    folder =
                        name: "test"
                        path: "/root"
                    client.post "folders/", folder, (err, res, body) =>
                        @err = err
                        @res = res
                        @body = body
                        done()

            it "Then error should not exist", ->
                should.not.exist @err

            it "And 200 should be returned as response code", ->
                @res.statusCode.should.be.equal 200

            it "And creationDate and modificationDate should be set", ->
                now = moment()
                body = @body

                should.exist body.creationDate
                should.exist body.lastModification
                body.creationDate.should.be.equal body.lastModification
                creationDate = moment body.creationDate
                creationDate.date().should.be.equal now.date()
                creationDate.month().should.be.equal now.month()


        describe "Try to create the same folder", ->
            it "When I send a request to create a folder", (done) ->
                folder =
                    name: "test"
                    path: "/root"
                client.post "folders/", folder, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 400 should be returned as response code", ->
                @res.statusCode.should.be.equal 400

    describe "Get folder", =>

        it "When I send a request to create a folder", (done) ->
            folder =
                name: "test2"
                path: "/root"
            @now = moment()
            client.post "folders/", folder, (err, res, body) =>
                @id = body.id
                done()

        it "And I send a request to get a folder", (done) ->
            client.get "folders/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And folder should be returned", ->
            @body.name.should.be.equal "test2"
            @body.path.should.be.equal "/root"

        it "And root folder lastModification should be updated", (done) ->
            @timeout(2 * 60 * 1000)
            setTimeout () =>
                client.get "folders/folders", (err, res, folders) =>
                    folder = folders.pop()
                    while folders.length > 0 and folder.name isnt 'root'
                        folder = folders.pop()
                    lastModification = moment folder.lastModification
                    (lastModification > @now).should.be.ok
                    done()
            , 1.5 * 60 * 1000


    describe "Rename folder", =>

        it "When I send a request to create a folder", (done) ->
            folder =
                name: "test_folder"
                path: "/root"
            @now = moment()
            client.post "folders/", folder, (err, res, body) =>
                @id = body.id
                done()

        it "And I send a request to rename the folder", (done) ->
            folder =
                name: "test_new_folder"
                path: "/root"
            client.put "folders/#{@id}", folder, (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And I send a request to get a folder", (done) ->
            client.get "folders/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "And error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And folder should be returned", ->
            @body.name.should.be.equal "test_new_folder"
            @body.path.should.be.equal "/root"

        it "And root folder lastModification should be updated", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and  folder.name isnt 'root'
                    folder = folders.pop()

                lastModification = moment folder.lastModification
                (lastModification > @now).should.be.ok
                done()


    describe "Find folders in a specific folder", =>

        it "When I send a request to get the root folder", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and  folder.name isnt 'root'
                    folder = folders.pop()
                @id = folder.id

                client.post "folders/folders", id: @id, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And two folders should be returned", ->
            @body.length.should.be.equal 3


    describe "Change folder path", =>

        it "When I send a request to create folders", (done) ->
            @now = moment()
            folder2 =
                name: "test_folder_2"
                path: "/root"
            folder3 =
                name: "test_folder_3"
                path: "/test_folder_3"
            folder4 =
                name: "test_folder_4"
                path: "/root/test_folder_2"
            client.post "folders/", folder2, (err, res, body) =>
                @id = body.id
                client.post "folders/", folder3, (err, res, body) =>
                    client.post "folders/", folder4, (err, res, body) =>
                        @idSubfolder = body.id
                        done()

        it "And I send a request to change the folder path", (done) ->
            folder =
                path: "/test_folder_3"
            client.put "folders/#{@id}", folder, (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And I send a request to get a folder", (done) ->
            client.get "folders/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "And error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And folder should be returned", ->
            @body.name.should.be.equal "test_folder_2"
            @body.path.should.be.equal "/test_folder_3"

        it "And subfolder path should be updated", (done) ->
            client.get "folders/#{@idSubfolder}", (err, res, body) =>
                body.path.should.be.equal "/test_folder_3/test_folder_2"
                done()

        it "And root folder lastModification should be updated", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and  folder.name isnt 'root'
                    folder = folders.pop()

                lastModification = moment folder.lastModification
                (lastModification > @now).should.be.ok
                done()


    describe "Find file in a specific folder", =>

        it "When I send a request to create a folder1", (done) ->
            folder =
                name: "folder1"
                path: ""
            client.post "folders/", folder, (err, res, body) =>
                @folderId = body.id
                done()

        it "When I send a request to create a file in folder1", (done) ->
            file =
                name: "file1"
                path: "/folder1"
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @id = body.id
                done()

        it "And I send a request to get a folder1", (done) ->
            client.post "folders/files/", {id: @folderId}, (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And one file should be returned", ->
            @body.length.should.be.equal 1


    describe "Download folder in zip format", =>
        archivePath = path.join '.', 'test-archive.zip'
        archiveDest = path.join '.', 'test-archive'

        before (done) =>
            rimraf archivePath, =>
                rimraf archiveDest, done

        it "When I send a request to create folders", (done) ->
            folder =
                name: "folder"
                path: ""
            client.post "folders/", folder, (err, res, body) =>
                @id = body.id
                folder =
                    name: "subfolder"
                    path: "/folder"
                client.post "folders/", folder, (err, res, body) =>
                    done()

        it "And I put files in this folders", (done) ->
            file =
                name: "test"
                path: "/folder"
            filePath = './test/fixtures/files/test.txt'
            client.sendFile 'files/', filePath, file, (err, res, body) =>
                file =
                    name: "test2"
                    path: "/folder/subfolder"
                filePath = './test/fixtures/files/test.txt'
                client.sendFile 'files/', filePath, file, (err, res, body) =>
                    should.not.exist err
                    done()

        it "And I send a request to get a folder", (done) ->
            urlPath = "folders/#{@id}/zip/folder"
            client.saveFile urlPath, archivePath, (err, res, body) =>
                @res = res

                decompress = new Decompress()
                    .src(archivePath)
                    .dest(archiveDest)
                    .use Decompress.zip(strip: 0)

                # Timeout is required to ensure the end of the upload. It looks
                # like the files app send a responsed while the uploading is
                # not fully finished.
                setTimeout =>
                    decompress.run (err, files) =>
                        should.not.exist err

                        isExist = fs.existsSync path.join archiveDest, 'test'
                        isExist.should.be.ok

                        subfolderPath = path.join archiveDest, 'subfolder'
                        isExist = fs.existsSync subfolderPath
                        isExist.should.be.ok

                        isExist = fs.existsSync path.join subfolderPath, 'test2'
                        isExist.should.be.ok
                        done()
                , 1000

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200


    describe "Delete folder", =>

        it "When I send a request to create a root folder", (done) ->
            folder =
                name: "root2"
                path: ""
            client.post "folders/", folder, (err, res, body) =>
                @rootId = body.id
                done()

        it "And I send a request to create a sub-folder", (done) ->
            folder =
                name: "test3"
                path: "/root2"
            client.post "folders/", folder, (err, res, body) =>
                @testId = body.id
                done()

        it "And I send a request to create a second sub-folder", (done) ->
            folder =
                name: "test4"
                path: "/root2"
            client.post "folders/", folder, (err, res, body) =>
                @testSubId = body.id
                done()

        it "And I send a request to create a sub-file", (done) ->
            file =
                name: "file"
                path: "/root2"
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @fileId = body.id
                done()


           it "And I send a request to remove a subfolder", (done) ->
            @now = moment()
            client.del "folders/#{@testSubId}/", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()


        it "Then root folder lastModification should be updated", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and folder.name isnt 'root2'
                    folder = folders.pop()

                lastModification = moment folder.lastModification
                (lastModification > @now).should.be.ok
                done()


           it "When I send a request to remove the root folder", (done) ->
            client.del "folders/#{@rootId}/", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 204 should be returned as response code", ->
            @res.statusCode.should.be.equal 204

        it "And root folder should be deleted", (done) ->
            client.get "folders/#{@rootId}/" , (err, res, body) ->
                res.statusCode.should.equal 404
                done()

        it "And sub-folder should be deleted", (done) ->
            client.get "folders/#{@testId}/" , (err, res, body) ->
                res.statusCode.should.equal 404
                done()

        it "And sub-file should be deleted", (done) ->
            client.get "files/#{@fileId}/" , (err, res, body) ->
                res.statusCode.should.equal 404
                done()


    describe "Change last modification date on file operations", =>

        it "When I send a request to create a folder", (done) ->

            folder =
                name: "rootfile"
                path: ""
            client.post "folders/", folder, (err, res, body) =>
                done()

        it "And I send a request to create a file in that folder", (done) ->
            file =
                name: "test"
                path: "/rootfile"
            @now = moment()
            client.sendFile 'files/', './test/fixtures/files/test.txt', file, (err, res, body) =>
                @id = (JSON.parse body).id
                done()

        it "Then root folder lastModification should be updated", (done) ->
            @timeout 2 * 60 * 1000
            setTimeout () =>
                client.get "folders/folders", (err, res, folders) =>
                    folder = folders.pop()
                    while folders.length > 0 and  folder.name isnt 'rootfile'
                        folder = folders.pop()

                    lastModification = moment folder.lastModification
                    (lastModification > @now).should.be.ok
                    done()
            , 1.5 * 60 * 1000

        it "And I send a request to rename a file in that folder", (done) ->
            file =
                name: "new_test3"
                path: "/rootfile"
            @now = moment()
            client.put "files/#{@id}", file, (err, res, body) =>
                @err = err
                @res = res
                done()

        it "Then root folder lastModification should be updated", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and  folder.name isnt 'rootfile'
                    folder = folders.pop()

                lastModification = moment folder.lastModification
                (lastModification > @now).should.be.ok
                done()

        it "And I send a request to delete a file in that folder", (done) ->
            file =
                name: "new_test3"
                path: "/rootfile"
            @now = moment()
            client.del "files/#{@id}", (err, res, body) =>
                done()

        it "Then root folder lastModification should be updated", (done) ->
            client.get "folders/folders", (err, res, folders) =>
                folder = folders.pop()
                while folders.length > 0 and  folder.name isnt 'rootfile'
                    folder = folders.pop()

                lastModification = moment folder.lastModification
                (lastModification > @now).should.be.ok
                done()
