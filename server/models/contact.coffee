<<<<<<< HEAD
americano = require 'americano-cozy-pouchdb'
=======
cozydb = require 'cozydb'
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

class DataPoint extends cozydb.Model
    @schema:
        name: String
        value: String
        type: String

module.exports = Contact = cozydb.getModel 'Contact',
    fn            : String
    n             : String
<<<<<<< HEAD
    datapoints    : (x) -> x
=======
    datapoints    : [DataPoint]
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
