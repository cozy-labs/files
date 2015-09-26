cozydb = require 'cozy-db-pouchdb'

class DataPoint extends cozydb.Model
    @schema:
        name: String
        value: String
        type: String

module.exports = Contact = cozydb.getModel 'Contact',
    fn            : String
    n             : String
    datapoints    : [DataPoint]

