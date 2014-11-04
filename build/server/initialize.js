// Generated by CoffeeScript 1.7.1
var File, Folder, RealtimeAdapter, feed, init;

RealtimeAdapter = require('cozy-realtime-adapter');

File = require('./models/file');

Folder = require('./models/folder');

feed = require('./lib/feed');

init = require('./helpers/init');

module.exports.afterStart = function(app, server, callback) {
  var realtime, updateIndex;
  feed.initialize(server);
  realtime = RealtimeAdapter({
    server: server
  }, ['file.*', 'folder.*', 'contact.*'], {
    resource: '/public/socket.io'
  }, init.updateIndex());
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
