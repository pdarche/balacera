import re
import zmq
import random
import sys
import time
import sqlite3
import smtplib
import string
import operator
import nltk
from nltk.corpus import stopwords

#ZERO MQ STUFF
port = "5556"
context = zmq.Context()
socket = context.socket(zmq.PAIR)
socket.connect("tcp://localhost:%s" % port)


#sqlite db connection
creation_time = 1351664279
conn = sqlite3.connect('balacera.db', isolation_level=None)
c = conn.cursor()    

while True:
    msg = socket.recv()
    if msg == "fire away":
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.ehlo()
        server.starttls()
        server.login('balaceratweets@gmail.com', 'balacera')
        server.sendmail('balaceratweets@gmail.com', [ 'luisdaniel@gmail.com', 'pdarche@gmail.com' ] , 'yo, there are more than 5 balacera tweets per second.  go check out twitter')
        server.close()
    print msg
    socket.send("email sent")
    time.sleep(1)
    
    # msg = msg.split(' ')
    # c = conn.cursor()
    # try:
    #     c.execute("SELECT * FROM tweets WHERE creation_time > %d", creation_time)
    # except sqlite3.Error, msg:
    #     print msg


def translate_non_alphanumerics(to_translate, translate_to=u''):
    not_letters_or_digits = u'!"%\'()*+,-./:;<=>?@[\]^_`{|}~&'
    translate_table = dict((ord(char), translate_to) for char in not_letters_or_digits)
    return to_translate.translate(translate_table)


def analyze_tweets():
    stopwords = stopwords.words('spanish')
    corpus = """"""

    try:
        for row in c.execute("SELECT * FROM tweets"): #WHERE creation_time < %r" % creation_time
            tweet = re.sub('\s+', ' ', row[1])
            tweet = translate_non_alphanumerics(unicode(tweet), translate_to=u'')
            tweet = tweet.lower()
            corpus += tweet + ' '
    except sqlite3.Error, msg:
        print msg

    word_list = corpus.split(' ')
    word_freq = {}

    for word in word_list:
        if word not in stopwords:
            count = word_freq.get(word, 0)
            word_freq[word] = count+1

    sorted_dict = sorted(word_freq.iteritems(), key=operator.itemgetter(1))
    sorted_dict.reverse()

    print sorted_dict[0:20]

