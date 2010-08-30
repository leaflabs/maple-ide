#!/usr/bin/env python
"""Pull the contents out of the html files in this directory and SCP
them to the website"""

# TODO [mbolivar] switch this to lxml or something else reasonable.
#   (it's gross and incorrect to parse non-regular languages with
#   regular expressions, so this code is buggy as-is)

from __future__ import with_statement

import os,tempfile,re,shutil

r1 = re.compile('href="./(.*?)\.html')
r2 = re.compile('src="./img/(.*?)"')
r3 = re.compile('(<h1>.*?</h1>)')

originals = [x for x in os.listdir('.') if x.endswith(".html")]
t = tempfile.mkdtemp()

def process_file(file_name):
    processed_lines = []
    with open(file_name,'r') as f:
        state = 'head'
        for l in f.readlines():
            if state == 'head' and '<!-- STARTDOC -->' in l:
                state = 'body'
                continue
            elif state == 'body':
                if '<!-- ENDDOC -->' in l:
                    state = 'done'
                    break
                l = r1.sub(r'href="../\1/',l)
                l = r2.sub(r'src="http://static.leaflabs.com/img/docs/\1"',l)
                l = r3.sub('',l)
                processed_lines.append(l)
        if state != 'done':
            return None
        return processed_lines

for f in originals:
    processed_contents = process_file(f)

    if processed_contents is not None:
        with open(os.path.join(t, f), 'w') as o:
            o.writelines(processed_contents)
        print "Processed " + f

cmd1 = "scp " + t + "/* leaf:STATIC_DOCS/"
print "Uploading html..."
print cmd1
os.system(cmd1)
cmd2 = "scp ./img/* leaf:static/img/docs/"
print "Uploading img..."
print cmd2
os.system(cmd2)

shutil.rmtree(t)
