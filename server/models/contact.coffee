americano = require 'americano-cozy-pouchdb'

module.exports = Contact = americano.getModel 'Contact',
    fn            : String
    n             : String
    datapoints    : (x) -> x
