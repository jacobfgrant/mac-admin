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
import argparse
import shutil


def inPath(exe):
    """Check PATH environment for executable."""
    for path in os.environ["PATH"].split(os.pathsep):
        path = path.strip('"')
        exe_path = os.path.join(path, exe)
        if os.path.isfile(exe_path):
            return exe_path
    return None


def isPackage(pkgDir):
    """Check the contents of a directory for the files/directories required for munki-pkg."""
    # Check for 'payload' or 'scripts' directories
    if not (os.path.isdir(os.path.join(pkgDir, 'payload')) or
            os.path.isdir(os.path.join(pkgDir, 'scripts'))):
        print >> sys.stderr, "munki-pkg-make:", pkgDir, "missing payload and scripts directories"
        return False
        
    # Check for 'Bom.txt'
    if not os.path.isfile(os.path.join(pkgDir, 'Bom.txt')):
        print >> sys.stderr, "munki-pkg-make:", pkgDir, "missing Bom.txt"
        return False
        
    # Check for 'build-info[.plist][.json][.yml]'
    for ext in ['.plist', '.json', '.yml']:
        if os.path.isfile(os.path.join(pkgDir, ('build-info' + ext))):
            return True
    
    print >> sys.stderr, "munki-pkg-make:", pkgDir, "missing build-info file"
    return False


def syncPermissions(pkgDir, quiet=False):
    """Sync the permissions to files/directories from Bom.txt file."""
    if quiet:
        return subprocess.call(['munkipkg', '--sync', pkgDir, '--quiet'])
    else:
        return subprocess.call(['munkipkg', '--sync', pkgDir])


def makePackage(pkgDir, quiet=False):
    """Build munki-pkg package."""
    if quiet:
        return subprocess.call(['munkipkg', pkgDir, '--quiet'])
    else:
        return subprocess.call(['munkipkg', pkgDir])


def movePackage(currentDir, pkgDir, quiet=False):
    """Move package file from munki-pkg directory to central location."""
    keepBuild=False
    
    # Check for build directory in pkgDir
    # Retun with error if does not exist
    pkgDirBuild = os.path.join(pkgDir, 'build')
    if not os.path.exists(pkgDirBuild):
        # Is this the best line?
        print >> sys.stderr, "munki-pkg-make: build directory not found in", pkgDir
        return
    
    # Check for build directory in currentDir
    # Create directory if does not exist
    currentDirBuild = os.path.join(currentDir, 'build')
    if not os.path.exists(currentDirBuild):
        os.makedirs(currentDirBuild)
    
    # Moves all files ending with '.pkg'
    # Deletes directory and all files
    for pkg in os.listdir(pkgDirBuild):
        if pkg.endswith('.pkg'):
            oldPkg = os.path.join(pkgDirBuild, pkg)
            newPkg = os.path.join(currentDirBuild, pkg)
            os.rename(oldPkg, newPkg)
            if not quiet:
                print >> sys.stdout, "munki-pkg-make:", pkg, "moved to", currentDirBuild
    if not keepBuild:
        shutil.rmtree(pkgDirBuild)
        if not quiet:
            print >> sys.stdout, "munki-pkg-make:", pkgDirBuild, "removed"
    return


def main():
    #
    mainParser = argparse.ArgumentParser(
        description='Syncs permissions and then builds multiple packages at a time using the munki-pkg tool.')
    mainParser.add_argument(
        '-q',
        '--quiet',
        action="store_true",
        help="Suppress normal output messages. Errors will still be printed to stderr.")
    mainParser.add_argument(
        '-d',
        '--directory',
        help="Runs munki-pkg-make.py on the given directory. Runs on current directory if none is given.",
        default='.')
    args = mainParser.parse_args()
    
    # Check if script is running as root
    if os.geteuid() != 0:
        print >> sys.stderr, "This script must be run as root"
        return 1
            
    # Check if munkipkg executable is in PATH env
    if not inPath('munkipkg'):
        print >> sys.stderr, "munkipkg not found in PATH"
        return 1
    
    currentDir = args.directory
    if not os.path.isdir(currentDir):
        print >> sys.stderr, currentDir, "is not a directory"
        return 1
        
    quiet = args.quiet
    
    if isPackage(currentDir):
        pkgDir = currentDir
        syncPermissions(pkgDir, quiet)
        makePackage(pkgDir, quiet)
    else:
        if not quiet:
            print >> sys.stdout, "munki-pkg-make: examining directories in", currentDir
        for subDir in os.listdir(currentDir):
            pkgDir = os.path.join(currentDir, subDir)
            if os.path.isdir(pkgDir):
                if isPackage(pkgDir):
                    syncPermissions(pkgDir, quiet)
                    makePackage(pkgDir, quiet)
                    movePackage(currentDir, pkgDir, quiet)
    
    return


if __name__ == "__main__":
    main()
