#!/usr/bin/python

#  munki-pkg-make.py
#
#
#  Created by Jacob F. Grant on 5/13/17.
#
#  Syncs permissions and builds all packages in a given directory
#  using munki-pkg.
#
#  Must be run as sudo/root.
#

import sys
import os
import getopt
import subprocess
import plistlib


def inPATH(exe):
    for path in os.environ["PATH"].split(os.pathsep):
        path = path.strip('"')
        exe_path = os.path.join(path, exe)
        if os.path.isfile(exe_path):
            return exe_path
    return None


def isPackage(pkgdir):
    if not (os.path.isdir(os.path.join(pkgdir, 'payload')) or os.path.isdir(os.path.join(pkgdir, 'scripts'))):
        return False
    
    if not os.path.isfile(os.path.join(pkgdir, 'Bom.txt')):
        return False
    
    for ext in ['.plist', '.json', '.yml']:
        if os.path.isfile(os.path.join(pkgdir, ('build-info' + ext))):
            return True
    
    return False


def syncPermissions(pkgdir):
    return subprocess.call(['munkipkg', '--sync', pkgdir])


def makePackage(pkgdir):
    return subprocess.call(['munkipkg', pkgdir])


def main():
    # Check if script is running as root
    if os.geteuid() != 0:
        print >> sys.stderr, "This script must be run as root"
        return 1
            
    # Check if munkipkg executable is in PATH env
    exe_path = inPATH('munkipkg')
    if not exe_path:
        print >> sys.stderr, "munkipkg not found in PATH"
        return 1
    
    cd = '.'
    for d in os.listdir(cd):
        pkgdir = os.path.join(cd, d)
        
        if os.path.isdir(pkgdir):
            if isPackage(pkgdir):
                syncPermissions(pkgdir)
                makePackage(pkgdir)


if __name__ == "__main__":
    main()
