Overview
--------

Tells you what's in your current Eve Online skill queue and when it will run out.

Requirements
------------

* An Eve Online account
* A version of the *reve* gem that supports the skill_queue api, like <http://github.com/dsander/reve/tree/master> (I couldn't get lisa's to install)
* A Google Account with AppEngine for Java enabled
* JRuby 1.3 or greater
* The following gems must be installed in your JRuby environment:
** warbler
** dm-core
** dm-validations
** dm-datastore-adapter
** dsander-reve
** hpricot (~>0.6.1)
** lstoll-rb-gae-support

Installation
------------

1. Copy appengine-web.xml.example to appengine-web.xml
2. Use "jruby -S warble" to create a skeve.war file and the tmp/war directory
3. "appcfg.sh update tmp/war/" to upload the application to Google