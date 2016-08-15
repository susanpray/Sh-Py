#!/usr/bin python
# -*- coding: UTF-8 -*-

import os
import sys
import argparse
import time

Localproduct={'ProductId' : 24,'VersionDetails' : {'BuildType' : 33,'BuildTime' : time.asctime(time.localtime()), 'Revision' : '3.1.1' }}


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--id", help="Assign the product id", type=int, required=False)
    parser.add_argument("-s", "--system", help="Assign the product system infomation", type=str, required=False)
    parser.add_argument("-v", "--version", help="Assign the product version", type=str, required=False)
    parser.add_argument("-b", "--buildtype", help="Assign the product build type", type=str, required=False)
    parser.add_argument("-t", "--buildtime", help="Assign the product build time", type=str, required=False)
    parser.add_argument("-r", "--revision", help="Assign the product revision", type=str, required=False)
    args = parser.parse_args()



    if args.system:
        print args.system
    if args.version:
        print args.version
    if args.buildtype:
        print args.buildtype
    if args.buildtime:
        print args.buildtime
    if args.revision:
        print args.revision
    
    while True:
        if Localproduct['ProductId'] == args.id:
    #             if args.version:
    #                 product['CurrentVersion'] = '.'.join(args.version.split('.')[:3])
    #                 product['VersionDetails']['BuildNum'] = args.version.split('.')[3]
            if args.buildtype:
                Localproduct['VersionDetails']['BuildType'] = args.buildtype
                
            if args.buildtime:
                Localproduct['VersionDetails']['BuildTime'] = args.buildtime
            if args.revision:
                Localproduct['VersionDetails']['Revision'] = args.revision
            print Localproduct
            break
       
    else:
        print 'Not exists the product(id: {0}).'.format(args.id)
        sys.exit(1)

