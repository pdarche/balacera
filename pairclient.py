import zmq
import random
import sys
import time
import sqlite3

port = "5556"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect("tcp://localhost:%s" % port)

#sqlite db connection
conn = sqlite3.connect('balacera.db', isolation_level=None)

while True:
    msg = socket.recv()
    print msg
    socket.send("client message to server1")
    time.sleep(1)
    
    # msg = msg.split(' ')

    # c = conn.cursor()
    # try:
    #     c.execute("SELECT * FROM tweets WHERE creation_time > %d", creation_time)
    # except sqlite3.Error, msg:
    #     print msg

