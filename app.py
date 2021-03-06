#!/usr/bin/env python
import tornado.web
import tornado.httpserver
import twitstream
from tornado import websocket
import json
import time
import sqlite3
from tornado.ioloop import time
import zmq

#zmq context and connection
port = "5556"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.bind("tcp://*:%s" % port)

#sqlite db connection
conn = sqlite3.connect('balacera.db', isolation_level=None)

#dict of global vars
GLOBALS = {
    'sockets': [],
    'pre_interval' : 0,
    'curr_interval' : 0,
    'pre_tweet_time' : "0",
    'analysis_start_time' : 0
    'begin_count' : False,
    'count' : 0 
}

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

def streamCallback(status):
    if "user" not in status:
        try:
            if options.debug:
                print >> sys.stderr, status
            return
        except:
            pass

    #parse the tweet for relevant information
    username = status["user"]["name"]
    screen_name = status["user"]["screen_name"]
    user_location = status["user"]["location"]
    tweet_text = status["text"]
    id = status["id_str"]
    created_at_seconds = time.mktime(time.strptime(status["created_at"], "%a %b %d %H:%M:%S +0000 %Y"))

    #tweet data tuple
    tweet_data = (id, tweet_text, created_at_seconds, screen_name, username)

    #insert tweet into db
    c = conn.cursor()
    try:
        c.execute("INSERT INTO tweets (id, tweet_text, creation_time, screen_name, username ) VALUES (?, ?, ?, ?, ? )", tweet_data)
    except sqlite3.Error, msg:
        print msg

    #set last tweet global equalt to tweet time  
    GLOBALS["pre_tweet_time"] = created_at_seconds

    #increment current tps value    
    GLOBALS["curr_interval"] += 1

    #push tweet to clients
    if len(GLOBALS['sockets']) > 0:
        GLOBALS['sockets'][0].write_message(status)
    

#test callback function
def testCallback(status):
    created_at_seconds = time.mktime(time.strptime(status["created_at"], "%a %b %d %H:%M:%S +0000 %Y"))
    GLOBALS["pre_tweet_time"] = created_at_seconds
    GLOBALS["curr_interval"] += 1
    print "tweet count: %s" % GLOBALS["curr_interval"]


def tweetVelocity():
    print "diff: %s" % str(GLOBALS['curr_interval'] - GLOBALS['pre_interval']) 
    vel = str(GLOBALS['curr_interval'] - GLOBALS['pre_interval']) 
    tweets = str(GLOBALS['curr_interval'])
    
    #push tps to connected clients, if there are any
    if len(GLOBALS['sockets']) > 0:
        GLOBALS['sockets'][0].write_message(tweets)

    #send message to other
    twe_time =  GLOBALS['pre_tweet_time'] 
    tweet_dict = { "pre_tweet_creation_time" : twe_time }
    time_str = "creation_time: {pre_tweet_creation_time}"
    creation_time = time_str.format(**tweet_dict)

    if vel > 5 and GLOBALS['begin_count'] == False:
        GLOBALS['begin_count'] = True
        GLOBALS['count'] += 1
    
    elif GLOBALS['begin_count'] == True and GLOBALS['count'] < 60:
        GLOBALS['count'] += 1

    elif GLOBALS['count'] == 60:
        socket.send(creation_time)
        msg = socket.recv()
        print msg
        
        GLOBALS['begin_count'] = False      
        GLOBALS['count'] = 0
    
    #set previous interval equal to current interval and set current interval equal to 0
    GLOBALS['pre_interval'] = GLOBALS['curr_interval']
    GLOBALS['curr_interval'] = 0

    
#socket classes
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


stream = twitstream.twitstream(method, options.username, options.password, testCallback, 
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
