#!/usr/bin/env python
import tornado.web
import tornado.httpserver
import twitstream
from tornado import websocket
import json
import time
import sqlite3
from tornado.ioloop import time

conn = sqlite3.connect('balacera.db', isolation_level=None)

GLOBALS = {
    'sockets': [],
    'pre_interval' : 0,
    'curr_interval' : 0
}

# curr_interval = []
# pre_interval = []

(options, args) = twitstream.parser.parse_args()

options.engine = 'tornado'    
options.username = 'citScience'
options.password = 'rascuala1303'


if len(args) < 1:
    twitstream.parser.error("requires one method argument")
else:
    method = args[0]
    if method not in twitstream.GETMETHODS and method not in twitstream.POSTPARAMS:
        raise NotImplementedError("Unknown method: %s" % method)

twitstream.ensure_credentials(options)

def testFunction(status):
    if "user" not in status:
        try:
            if options.debug:
                print >> sys.stderr, status
            return
        except:
            pass

    username = status["user"]["name"]
    screen_name = status["user"]["screen_name"]
    user_location = status["user"]["location"]
    tweet_text = status["text"]
    id = status["id_str"]
    created_at_seconds = time.mktime(time.strptime(status["created_at"], "%a %b %d %H:%M:%S +0000 %Y"))

    tweet_data = (id, tweet_text, created_at_seconds, screen_name, username)

    c = conn.cursor()
    try:
        c.execute("INSERT INTO tweets (id, tweet_text, creation_time, screen_name, username ) VALUES (?, ?, ?, ?, ? )", tweet_data)
    except sqlite3.Error, msg:
        print msg

    # if len(GLOBALS['sockets']) > 0:
    #     GLOBALS['sockets'][0].write_message(status)
    # print "%s:\t%s\n" % (status.get('user', {}).get('screen_name'), status.get('text'))	

def funFunc(status):
    # global curr_interval
    GLOBALS["curr_interval"] += 1
    print "current number of tweets: %s" % str(GLOBALS['curr_interval'])

def tweetVelocity():
    print "diff: %s" % str(GLOBALS['curr_interval'] - GLOBALS['pre_interval']) 
    vel = str(GLOBALS['curr_interval'] - GLOBALS['pre_interval']) 
    tweets = str(GLOBALS['curr_interval'])
    if len(GLOBALS['sockets']) > 0:
        GLOBALS['sockets'][0].write_message(tweets)
    GLOBALS['pre_interval'] = GLOBALS['curr_interval']
    GLOBALS['curr_interval'] = 0
    

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("templates/tweetInfo.html")

class ClientSocket(websocket.WebSocketHandler):
    def open(self):
        GLOBALS['sockets'].append(self)
        print "WebSocket opened"

    def on_close(self):
        print "WebSocket closed"
        GLOBALS['sockets'].remove(self)

class Announcer(tornado.web.RequestHandler):
    def get(self, *args, **kwargs):
        data = self.get_argument('data')
        for socket in GLOBALS['sockets']:
            socket.write_message(data)
        self.write('Posted')

stream = twitstream.twitstream(method, options.username, options.password, funFunc, 
            defaultdata=args[1:], debug=options.debug, engine=options.engine)

if __name__ == "__main__":
	app = tornado.web.Application(
		handlers = [
            (r"/", MainHandler),
            (r"/socket", ClientSocket),
            (r"/push", Announcer), 
        ] 
	)
	http_server = tornado.httpserver.HTTPServer(app)
	http_server.listen(8000)
	stream.run(tweetVelocity)
