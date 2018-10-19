#!/usr/bin/env python2
import sys, json

print '-------------------------------------------------'
print '|    VM Name    |   Public IP   |   Private IP  |'
print '-------------------------------------------------'
for val in json.load(sys.stdin):
    print '|{!s:^15}|{!s:^15}|{!s:^15}|'.format(val['virtualMachine']['name'], val['virtualMachine']['network']['publicIpAddresses'][0]["ipAddress"], val['virtualMachine']['network']['privateIpAddresses'][0], end=" | ")
print '-------------------------------------------------'