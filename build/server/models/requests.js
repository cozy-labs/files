<<<<<<< HEAD
// Generated by CoffeeScript 1.7.1
=======
// Generated by CoffeeScript 1.9.3
var cozydb;

cozydb = require('cozydb');

>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
module.exports = {
  file: {
    all: cozydb.defaultRequests.all,
    byTag: cozydb.defaultRequests.tags,
    byFolder: cozydb.defaultRequests.by('path'),
    byFullPath: function(doc) {
      return emit(doc.path + '/' + doc.name, doc);
    }
  },
  folder: {
    all: cozydb.defaultRequests.all,
    byTag: cozydb.defaultRequests.tags,
    byFolder: cozydb.defaultRequests.by('path'),
    byFullPath: function(doc) {
      return emit(doc.path + '/' + doc.name, doc);
    }
  },
  contact: {
    all: cozydb.defaultRequests.all
  }
};
