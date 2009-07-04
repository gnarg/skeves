Overview
--------

Tells you what's in your current Eve Online skill queue and when it will run out.

Requirements
------------

* An Eve Online account
* A version of the *reve* gem that supports the skill_queue api, like <http://github.com/dsander/reve/tree/master> (I couldn't get lisa's to install)
* A web server that can run Rack apps

Installation
------------

1. Copy config/eve_auth.yml.example to config/eve_auth.yml
1. Fill in your own USER_ID and API_KEY (<http://www.eveonline.com/api/default.asp>)
1. Start 'er up as a regular Rack app
