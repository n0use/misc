#!/usr/bin/env /usr/local/bin/python
# 

#import bsddb
import sys, re
import dbhash

escapes = ''.join([chr(char) for char in range(1, 32)])

if len(sys.argv) > 1:
    fname = sys.argv[1]
else:
    print "Usage %s: filename\n - will convert a dbhash back to text and dump to stdout" % (sys.argv[0])
    sys.exit(1)

#for k, v in bsddb.btopen("/etc/aliases.db").iteritems():
for k, v in dbhash.open(fname).iteritems():
#    key = k.translate(None, escapes)
#    val = v.translate(None, escapes)
#    key = k.decode('ascii', 'ignore')
#    val = v.decode('ascii', 'ignore')
    key = re.sub('.$', '', k)
    val = re.sub('.$', '', v)
    print "%s: %s" % (key, val)

sys.exit(0)
