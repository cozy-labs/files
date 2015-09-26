BaseView = require '../lib/base_view'
Modal = require "./modal"
client = require "../lib/client"
CozyClearanceModal = require "cozy-clearance/modal_share_view"

# extends the cozy-clearance modal to files specifics
module.exports = class ModalShareView extends CozyClearanceModal

    # display inherited details on summary's click
    events: -> _.extend super,
        'click #inherited-share-summary a': =>
            @$('#inherited-share-list').show()
            @$('#inherited-share-summary').hide()

    # retrieve inherited rules
    initialize: (options) ->
        @type = @model.get('type')
        super
        @summaryemails = []
        client.get "clearance/#{@model.id}", (err, data) =>
            if err
                Modal.error 'server error occured', => @$el.modal 'hide'
            else
                @inherited = data.inherited

                @forcedShared = @inherited.length > 0

                @makePublic() if @isPrivateClearance()

                # actually render content
                @refresh()

    # allow rw permissions for folder, customize message depending on type
    permissions: ->
        if @type is 'folder'
            'r': 'perm r folder'
            'rw': 'perm rw folder'
        else
            'r': t 'perm r file'

    # do not allow adding permissions for user who already have them by inheritance
    typeaheadFilter: (item) =>
        email = item.toString().split(';')[0]
        super and email not in @summaryemails

    # force 'shared' display if forced shared by inheritance
    getRenderData: ->
        out = super
        if @forcedShared
            if @inherited?
                if @inherited[0].clearance is 'public'
                    out.clearance = 'public'
                else
                    guests = []
                    for folder in @inherited
                        guests.push guest for guest in folder.clearance
                    out.clearance = @getClearanceWithContacts guests
        return out

    # ignore click on 'private' button when forced public by inheritance
    makePrivate: ->
        return if @forcedShared
        super

    # support forced public by inheritance and add inherited summary
    afterRender: () ->
        super

        if @forcedShared
            @$('#share-public').addClass 'toggled'
            @$('#select-mode-section').hide()

            if @inherited[0].clearance is 'public'
                text = t('forced public')
                @$('#select-mode-section').after $('<p>').text text
                $('#share-input').hide()
                $('#add-contact').hide()
                $('.input-group').prev('p').hide()
                $('#public-url').removeClass 'disabled'
                setTimeout ->
                    $('#public-url').focus().select()
                , 200
            else
                text = t('forced shared')
                @$('#select-mode-section').after $('<p>').text text
                $('#share-input').hide()
                $('#add-contact').hide()
                $('.input-group').prev('p').hide()
                $('.input-group').prev('p').prev('p').hide()
                $('#public-url').prev('p').hide()
                $('#public-url').prev('p').prev('p').hide()
                $('#public-url').hide()
                $('.revoke').hide()
                $('.changeperm').prop 'disabled', true

            $('#modal-dialog-no').hide()
            $('#modal-dialog-yes').html t('ok')

        else
            listitems = []
            summary = []

            for folder in @inherited when folder.clearance.length isnt 0
                text = t('inherited from') + folder.name
                listitems.push $('<li>').addClass('header').text text
                for rule in folder.clearance when folder.clearance
                    summary.push rule.email
                    listitems.push $('<li>').text rule.email

            if summary.length isnt 0
                @summaryemails = summary
                text = t('also have access') + ': ' + summary.join(', ') + '. '
                summary = $('<div id="inherited-share-summary">').text text
                summary.append $('<a>').text t('details')
                list = $('<ul id="inherited-share-list">').hide()
                list.append item for item in listitems
                @$('#share-list').after summary, list

        # if there is a writing guest
        guestCanWrite = _.findWhere @model.get('clearance'), perm: 'rw'
        if guestCanWrite
            checkbox = $('<input id="notifs" type="checkbox">')
            checkbox.prop 'checked', @model.get 'changeNotification'
            text = t('change notif')
            html = '<label class="notifs-label" for="notifs">'
            label = $(html).append checkbox, text
            @$('#share-list').after label


    # include the changes notification in PUT request
    saveData: ->
        changeNotification = @$('#notifs').prop('checked') or false
        _.extend super, changeNotification: changeNotification

    onYes: ->
        if @forcedShared
            @close()
        else
            super()

    onNo: ->
        if @forcedShared
            @close()
        else
            super()

