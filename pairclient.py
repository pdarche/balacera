import zmq
import random
import sys
import time

port = "5556"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect("tcp://localhost:%s" % port)

while True:
    msg = socket.recv()
    msg = msg.split(' ')
    accel = int(msg[1])
    if accel > 5:
    	print "processing!"
    	socket.send("client message to server1")
    	time.sleep(1)
    else:
    	socket.send("client message to server1")
    	time.sleep(1)

