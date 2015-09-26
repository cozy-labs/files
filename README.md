# [Cozy](http://cozy.io) Files

<<<<<<< HEAD
Standalone version of the Cozy Files application.

[See demo](https://demo.cozycloud.cc/apps/files)

Features:
=======
Cozy Files makes your file management easy. Main features are:
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

* File tree
* Files and folders upload.
* Files and folders sharing (via URLs)
* Files and folders search
* Files and folders tagging (and search by tag)

## Install

<<<<<<< HEAD
    sudo npm install cozy-files -g
=======
We assume here that the Cozy platform is correctly [installed](http://cozy.io/host/install.html)
 on your server.

You can simply install the Files application via the app registry. Click on the *Chose Your Apps* button located on the right of your Cozy Home.

From the command line you can type this command:

    cozy-monitor install files


## Contribution
>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20

## Run

Run it from any directory, data will be stored in the `~/.cozy-files` folder:

    cozy-files

## Hack

Get sources:

    git clone https://github.com/cozy-labs/cozy-files.git

Run it with:

    npm start

Each modification of the server requires a new build, here is how to run a build:

    cake build

Each modification of the client requires a specific build too.

    cd client
    brunch build

<<<<<<< HEAD
=======
## Tests

Cozy Files manages files in your Cozy platform.

![Build
Status](https://travis-ci.org/mycozycloud/cozy-files.png?branch=master)

To run tests, use the following command into the Cozy Files folder:

    npm test

That's how Travis run the tests and it's what should be working when pushing code. It will run the tests against the `build/` version of the code.

During development, you can use:

    cake tests

That will also run the tests on both the server and the client but you don't have to build your code each time since it will run them against `server/` and `client/` rather than `build/`.

If you only want to run the tests for the server, use

    cake tests:server

If you only want to run the tests for the client, use

    cake tests:client

In order to run the tests, you must have the Data System started. Also, for client tests, you need to install [CasperJS](http://casperjs.org/)

There are two options that can be used:

* `--use-js` will run the tests based on the `build/` folder
* `--use-server` will start a server during client tests

>>>>>>> 0759785e6a73787ae4d6166d455c268bcac75f20
## Icons

by [iconmonstr](http://iconmonstr.com/)
and [momentum](http://www.momentumdesignlab.com/)

Main icon by [Elegant Themes](http://www.elegantthemes.com/blog/freebie-of-the-week/beautiful-flat-icons-for-free).

## License

Cozy Files is developed by Cozy Cloud and distributed under the AGPL v3 license.

## What is Cozy?

![Cozy Logo](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)

[Cozy](http://cozy.io) is a platform that brings all your web services in the
same private space.  With it, your web apps and your devices can share data
easily, providing you
with a new experience. You can install Cozy on your own hardware where no one
profiles you.

## Community

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum](https://forum.cozy.io/)
* Posting issues on the [Github repos](https://github.com/cozy/)
* Mentioning us on [Twitter](http://twitter.com/mycozycloud)
