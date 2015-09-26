<<<<<<< HEAD
// Generated by CoffeeScript 1.7.1
var americano, errorHandler, fs, localization, path, port, start;
=======
// Generated by CoffeeScript 1.9.3
var americano, application, errorHandler, initialize;
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

americano = require('americano');

fs = require('fs');

path = require('path');

localization = require('./server/lib/localization_manager');

errorHandler = require('./server/middlewares/errors');

start = function(options, callback) {
  var config, configPath;
  if (options == null) {
    options = {};
  }
  options.name = 'Files';
  options.port = options.port;
  options.host = process.env.HOST || "0.0.0.0";
  options.root = options.root || __dirname;
  configPath = path.join(process.cwd(), 'config.json');
  if (!fs.existsSync(configPath)) {
    config = {};
    fs.writeFileSync(configPath, JSON.stringify(config));
  }
  return localization.initialize(function() {
    return americano.start(options, function(app, server) {
      var initialize;
      initialize = require('./server/initialize');
      app.server = server;
      app.use(errorHandler);
      return initialize.afterStart(app, server, function(err) {
        return callback(err, app, server);
      });
    });
  });
};

if (!module.parent) {
  port = process.env.PORT || 9113;
  start({
    port: port
  }, function(err) {});
}

module.exports.start = start;
