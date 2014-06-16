BaseView = require '../lib/base_view'
ModalView = require "./modal"
ModalShareView = require "./modal_share"
TagsView = require "./tags"

client = require "../helpers/client"

module.exports = class FileView extends BaseView

    className      : 'folder-row'
    tagName        : 'tr'
    templateNormal : require './templates/file'
    templateEdit   : require './templates/file_edit'
    templateSearch : require './templates/file_search'

    events:
        'click a.file-delete'      : 'onDeleteClicked'
        'click a.file-share'       : 'onShare'
        'click a.file-edit'        : 'onEditClicked'
        'click a.file-edit-save'   : 'onSaveClicked'
        'click a.file-edit-cancel' : 'render'
        'click a.file-move'        : 'onMoveClicked'
        'keydown input'            : 'onKeyPress'

    template: (args) ->
        if app.folderView.model.get("type") is "search"
            @templateSearch args
        else
            @templateNormal args

    initialize: ->
        @listenTo @model, 'change', @render

    onDeleteClicked: ->
        new ModalView t("modal are you sure"), t("modal delete msg"), t("modal delete ok"), t("modal cancel"), (confirm) =>
            if confirm
                @model.destroy
                    error: ->
                        ModalView.error t("modal delete error")

    onEditClicked: ->
        width = @$(".caption").width() + 10
        model = @model.toJSON()
        model.class = 'folder' unless model.class?
        @$el.html @templateEdit(model: model)
        @tags = new TagsView
            el: @$('.tags')
            model: @model
        @tags.render()
        @$(".file-edit-name").width(width)
        @$(".file-edit-name").focus()


        # we only want to select the part before the file extension
        lastIndexOfDot = model.name.lastIndexOf '.'
        lastIndexOfDot = model.name.length if lastIndexOfDot is -1
        input = @$(".file-edit-name")[0]
        if typeof input.selectionStart isnt "undefined"
            input.selectionStart = 0
            input.selectionEnd = lastIndexOfDot
        else if document.selection && document.selection.createRange
            # IE Branch...
            input.select()
            range = document.selection.createRange()
            range.collapse true
            range.moveEnd "character", lastIndexOfDot
            range.moveStart "character", 0
            range.select()

    onShare: -> new ModalShareView model: @model

    onSaveClicked: ->
        name = @$('.file-edit-name').val()

        if name and name isnt ""

            @model.save name: name,
                wait: true
                success: (data) =>
                    @render()
                error: (model, err) =>
                    console.log err
                    if err.status is 400
                        ModalView.error t("modal error in use")
                    else
                        ModalView.error t("modal error rename")
        else
            ModalView.error t("modal error empty name")


    # Display Move widget and handle move operation if user confirms.
    onMoveClicked: =>
        formTemplate = """
            <div class="move-widget">
            <span> #{t 'move element to'}: </span>
            <select class="move-select"></select>
            <button class="button btn move-btn">
                #{t 'move'}
            </button>
            <button class="btn btn-link cancel-move-btn">
                #{t 'cancel'}
            </button>
            </div>
        """

        errorTemplate = """
            <div>
            <span class="error">An error occured while moving element #{@model.get 'name'}.</span>
            </div>
        """

        movedTemplate = (path) ->
            """
            <div id="moved-infos">
            <span>file successfully moved to /#{path}.</span>
            <button class="btn btn-link cancel-move-btn">
                #{t 'cancel'}
            </button>
            </div>
        """

        optionTemplate =  (path) -> """
            <option value="#{path}">#{path}</option>
        """

        firstCell = @$el.find('td:first-child')

        client.get 'folders/list', (err, paths) =>
            if err
                alert err
            else
                currentPath = @model.get('path')

                # Add root folder to list.
                paths.push '/' if currentPath isnt ""

                # Fill folder combobox with folder list.
                moveForm = $ formTemplate
                for path in paths
                    if path isnt currentPath
                        moveForm.find('select').append optionTemplate path

                # Cancel move action on cancel clicked.
                cancelButton =  moveForm.find(".cancel-move-btn")
                cancelButton.click ->
                    moveForm.remove()

                # Perform move operation on move clicked.
                moveButton = moveForm.find(".move-btn")
                moveButton.click =>

                    # Show loading
                    moveButton.html t "moving..."

                    # Get path and url information.
                    path = $(".move-select").val().substring 1
                    id = @model.get 'id'
                    previousPath = @model.get 'path'
                    type = @model.get 'type'

                    # Stop render sync.
                    @stopListening @model
                    @model.collection.socketListener.pause @model, null,
                        ignoreMySocketNotification: true

                    showMoveResult = =>
                        moveForm.fadeOut()
                        moveForm.remove()
                        movedInfos = $ movedTemplate path
                        firstCell.append movedInfos
                        cancelButton =  movedInfos.find(".cancel-move-btn")
                        movedInfos.click =>
                            data = path: previousPath
                            client.put "#{type}s/#{id}", data, (err) =>
                                if err
                                    alert 'An error occured while canceling.'
                                else
                                    movedInfos.fadeOut()

                    # Can't use Backbone model due to a weird sync
                    # I can't figure out what is causing view to re-render.
                    client.put "#{type}s/#{id}", path: path, (err) =>
                        if err
                            firstCell.append errorTemplate
                        else
                            showMoveResult()

                        # Put back synchronization.
                        @model.collection.socketListener.resume @model, null,
                            ignoreMySocketNotification: true
                        @listenTo @model, 'change', @render

                @$el.find('td:first-child').append moveForm



    onKeyPress: (e) =>
        if e.keyCode is 13
            @onSaveClicked()
        else if e.keyCode is 27
            @render()

    afterRender: ->
        @tags = new TagsView
            el: @$('.tags')
            model: @model
        @tags.render()
