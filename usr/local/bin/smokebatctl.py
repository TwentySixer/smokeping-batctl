#!/usr/bin/python3

import sys
import logging
import os
from queue import Queue # Python 3.x
from threading import Thread
import re


#logging.basicConfig( level=logging.DEBUG)

#print(len(sys.argv))
#print(sys.argv)

# quick and dirty
pings = sys.argv[2] # anzahl pings

def batctl(mac):

    # batctl muß als root laufen, sudoers
    # smokeping ALL=(ALL) NOPASSWD: ALL
    stream = os.popen('sudo /usr/sbin/batctl ping -c ' + pings + ' ' + mac)
    output = stream.read()
    # output quick and dirty
    msg = mac + '    :'

    regex = r"(?:(?<=time=))(.[0-9.]*)"
    data = output.splitlines()  #zeilenweise
    for x in range(1,(int(pings)+1)):  # ping anzahl zeilen auswerten
        match = re.search(regex, data[x])
        if match != None:
            msg += ' '+str(round(float(match.group(0)),1))
        else:
            msg += ' -'
    return msg

que = Queue()           # Python 3.x

threads_list = list()

for x in range(3,len(sys.argv)):
#    print(sys.argv[x]);
    threads_list.append(Thread(target=lambda q, arg1: q.put(batctl(arg1)), args=(que, sys.argv[x])))
    threads_list[-1].start() # start the thread we just created           


# Join all the threads
for t in threads_list:
    t.join()

# Check thread's return value
result = ''
while not que.empty():
    result += que.get()+"\n"
#    print(que.get(), flush=True)
    
sys.stdout.write(result)
#print(result)       # Python 3.x
#print(result, flush=True)
sys.stderr.write(result)

# 10.62.0.103          : 420 165 - - - - - - - 576 - - - - 825 - - - - -
