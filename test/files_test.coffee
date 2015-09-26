should = require('chai').should()
americano = require 'americano'
moment = require 'moment'

helpers = require './helpers'
client = helpers.getClient()
dsClient = helpers.getClient 'http://localhost:9101/'

if process.env.NODE_ENV in ['test', 'production']
    dsClient.setBasicAuth process.env.NAME, process.env.TOKEN

describe "Files management", ->

    before helpers.startApp
    before helpers.cleanDB
    after helpers.stopApp
    after helpers.cleanDB

    describe "Create file", ->

        describe "Create a new file", ->
            it "When I send a request to create a file", (done) ->
                file =
                    name: "test"
                    lastModification: "Tue Feb 03 2015 16:35:23 GMT+0100 (CET)"
                    path: ""
                TESTFILE = './test/fixtures/files/test.txt'
                client.sendFile 'files/', TESTFILE, file, (err, res, body) =>
                    @res = res
                    @body = body
                    done()

            it "Then error should not exist", ->
                should.not.exist @err

            it "And 200 should be returned as response code", ->
                @res.statusCode.should.be.equal 200

            it "And creationDate and modificationDate should be set", ->
                now = moment()
                body = JSON.parse @body

                should.exist body.creationDate
                creationDate = moment(body.creationDate)
                creationDate.date().should.be.equal now.date()
                creationDate.month().should.be.equal now.month()
                should.exist body.lastModification
                body.lastModification.should.equal '2015-02-03T15:35:23.000Z'


        describe "Try to create the same file", ->
            it "When I send a request to create a file", (done) ->
                file =
                    name: "test"
                    path: ""
                path = './test/fixtures/files/test.txt'
                client.sendFile 'files/', path, file, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = body
                    done()

            it "Then 400 should be returned as response code", ->
                @res.statusCode.should.be.equal 400

        describe "Try to create the same file with overwrite option", ->
            it "When I send a request to create a file", (done) ->
                file =
                    name: "test"
                    path: ""
                    overwrite: "true"
                path = './test/fixtures/files/test2.txt'
                client.sendFile 'files/', path, file, (err, res, body) =>
                    @err = err
                    @res = res
                    @body = JSON.parse body
                    done()

            it "Then 200 should be returned as response code", ->
                @res.statusCode.should.be.equal 200

            it "And its content should be overriden", (done) ->
                client.get "files/#{@body.id}/attach/#{@body.name}", (err, res, body) ->
                    should.not.exist err
                    should.exist res
                    should.exist body
                    body.should.equal "Does overwrite work?\n"
                    done()
                , false


    describe "Get file", =>

        it "When I send a request to create a file", (done) ->
            file =
                name: "test2"
                path: ""
            client.sendFile 'files/', './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @body = body
                @id = body.id
                done()

        it "And I send a request to get a file", (done) ->
            client.get "files/#{@id}", (err, res, body) =>
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
            @body.path.should.be.equal ""


    describe "Rename file", =>

        it "When I send a request to create a file", (done) ->
            file =
                name: "test3"
                path: ""
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @id = body.id
                done()

        it "And I send a request to rename the file", (done) ->
            @timeout 3000
            file =
                name: "new_test3"
                path: ""
            client.put "files/#{@id}", file, (err, res, body) =>
                @err = err
                @res = res
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And I send a request to get a file", (done) ->
            client.get "files/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "And error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And file should be returned", ->
            @body.name.should.be.equal "new_test3"
            @body.path.should.be.equal ""


    describe "Change path of a file", =>

        it "When I send a request to create a file", (done) ->
            file =
                name: "test4"
                path: ""
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @id = body.id
                done()

        it "And I send a request to change the path of the file", (done) ->
            @timeout 3000
            file =
                path: "perso"
            client.put "files/#{@id}", file, (err, res, body) =>
                @err = err
                @res = res
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And I send a request to get a file", (done) ->
            client.get "files/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "And error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And file should be returned with the right path and the same name", ->
            @body.name.should.be.equal "test4"
            @body.path.should.be.equal "/perso"


    describe "Delete file", =>

        it "When I send a request to create a file", (done) ->
            file =
                name: "test5"
                path: ""
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @id = body.id
                done()

        it "Then we retrieve the binary ID", (done) ->
            dsClient.get "data/#{@id}/", (err, res, body) =>
                should.exist body.binary
                @binaryID = body.binary.file.id
                done()

        it "And I send a request to remove the file", (done) ->
            @timeout 3000
            client.del "files/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And file should be deleted", (done) ->
            client.get "files/#{@id}" , (err, res, body) ->
                res.statusCode.should.equal 404
                done()

        it "And the binary should be deleted", (done) ->
            dsClient.get "data/#{@binaryID}/", (err, res, body) ->
                should.exist body.error
                done()


    describe "Tag file", =>
        it "When I send a request to create a file", (done) ->
            file =
                name: "testtags"
                path: ""
            client.sendFile "files/", './test/fixtures/files/test.txt', file, (err, res, body) =>
                body = JSON.parse(body)
                @id = body.id
                done()

        it "And I send a request to tag the file", (done) ->
            file =
                name: "testtags"
                path: ""
                tags: ["tag1", "tag2"]
            client.put "files/#{@id}", file, (err, res, body) =>
                @err = err
                @res = res
                done()

        it "Then error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And I send a request to get a file", (done) ->
            client.get "files/#{@id}", (err, res, body) =>
                @err = err
                @res = res
                @body = body
                done()

        it "And error should not exist", ->
            should.not.exist @err

        it "And 200 should be returned as response code", ->
            @res.statusCode.should.be.equal 200

        it "And file should have tags", ->
            @body.tags[0].should.be.equal "tag1"
            @body.tags[1].should.be.equal "tag2"
