# [Cozy](http://cozy.io) Files

Standalone version of the Cozy Files application.

[See demo](https://demo.cozycloud.cc/apps/files)

Features:

* File Tree
* File and Folder upload.
* File and Folder sharing (via URLs)
* File search
* File and Folder tagging (and search by tag)

## Install

    sudo npm install cozy-files -g

## Run

Run it from any directory, data will be stored in the `~/.cozy-files` folder:

    cozy-files

## Hack

Get sources:

    git clone https://github.com/cozy-labs/cozy-files.git

Run it with:

    npm start

Each modification of the server requires a new build, here is how to run a
build:

    cake build

Each modification of the client requires a specific build too.

    cd client
    brunch build

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
* Posting on our [Forum](https://groups.google.com/forum/?fromgroups#!forum/cozy-cloud)
* Posting issues on the [Github repos](https://github.com/mycozycloud/)
* Mentioning us on [Twitter](http://twitter.com/mycozycloud)
