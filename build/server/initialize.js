<<<<<<< HEAD
// Generated by CoffeeScript 1.7.1
var File, Folder, RealtimeAdapter, feed, init;
=======
// Generated by CoffeeScript 1.9.3
var File, Folder, RealtimeAdapter, feed, init, localization;

localization = require('./lib/localization_manager');
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

RealtimeAdapter = require('cozy-realtime-adapter');

File = require('./models/file');

Folder = require('./models/folder');

feed = require('./lib/feed');

init = require('./helpers/init');

module.exports.afterStart = function(app, server, callback) {
  var realtime, updateIndex;
  feed.initialize(server);
<<<<<<< HEAD
  realtime = RealtimeAdapter({
    server: server
  }, ['file.*', 'folder.*', 'contact.*'], {
    resource: '/public/socket.io'
  }, init.updateIndex());
=======
  realtime = RealtimeAdapter(server, ['file.*', 'folder.*', 'contact.*'], {
    path: '/public/socket.io'
  });
  init.updateIndex();
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
  updateIndex = function(type, id) {
    return type.find(id, (function(_this) {
      return function(err, file) {
        if (err) {
          if (err) {
            return console.log("updateIndex err", err.stack);
          }
        }
        if (!file) {
          return console.log("updateIndex : no file", id);
        }
        return file.index(['name'], function(err) {});
      };
    })(this));
  };
  if (callback != null) {
    return callback(null, app, server);
  }
};
