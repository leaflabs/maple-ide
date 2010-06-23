#!/usr/bin/env python
"""This script is a memory hog; it searches and converts files in RAM for 
speed and laziness"""

import os,tempfile,re

r1 = re.compile('href="./(.*?)\.html')
r2 = re.compile('src="./img/(.*?)"')
r3 = re.compile('(<h1>.*?</h1>)')

originals = filter(lambda x: x.endswith(".html"), os.listdir('.'))
processed = list()
t = tempfile.mkdtemp()

for f in originals:
    f = file(f)
    state = 0
    cache = list()
    for l in f.readlines():
        if(state == 0):
            if l.find("<!-- STARTDOC -->") != -1:
                state = 1
                continue
        elif(state == 1):
            if l.find("<!-- ENDDOC -->") != -1:
                state = 2
                break
            l = r1.sub(r'href="../\1/',l)
            l = r2.sub(r'src="http://static.leaflabs.com/img/docs/\1"',l)
            l = r3.sub('',l)
            cache.append(l)

    if state != 2:
        print "Skipping " + f.name
        continue

    o = open(t + "/" + f.name,'w')
    o.writelines(cache);
    o.close()
    print "Processed " + f.name
    processed.append(o)

#print processed

cmd1 = "scp " + t + "/* leaf:STATIC_DOCS/"
print "Uploading html..."
print cmd1
os.system(cmd1)
cmd2 = "scp ./img/* leaf:static/img/docs/"
print "Uploading img..."
print cmd2
os.system(cmd2)

for f in processed:
    os.unlink(f.name)

os.rmdir(t)
