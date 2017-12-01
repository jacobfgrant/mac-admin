#!/usr/bin/python

#  buildLaunchDPkg.py
#
#
#  Created by Jacob F. Grant
#
#  Written: 11/30/17
#  Updated: 12/01/17
#

"""
buildLaunchDPkg

Packages a launchd LaunchDaemon/LaunchAgent into a
pkg file using the munkipkg tool.

https://github.com/munki/munki-pkg
"""


# Import modules

import sys
import os
import time
import plistlib
import subprocess
import argparse
import shutil
from random import randint
from xml.parsers.expat import ExpatError


# Functions

def gather_launchdinfo(args):
    """Gathers info from input args"""
    launchdinfo = {}

    # Input info
    launchdinfo['type'] = args.type
    launchdinfo['version'] = args.version
    launchdinfo['plist'] = args.plist

    # Read plist
    try:
        launchdinfo['plistinfo'] = plistlib.readPlist(launchdinfo['plist'])
    except IOError:
        print 'ERROR: Plist file does not exist'
        exit()
    except ExpatError:
        print 'ERROR: Invalid .plist file'
        exit()

    # Name
    launchdinfo['name'] = launchdinfo['plistinfo']['Label']

    # Install location
    if launchdinfo['type'] == 'daemon':
        location = '/Library/LaunchDaemons/'
    else:
        location = '/Library/LaunchAgents/'
    launchdinfo['location'] = os.path.join(location, launchdinfo['name'])

    # Package name
    pkgname = launchdinfo['name'].split('.')[-1]
    launchdinfo['pkgname'] = pkgname + '-launch' + launchdinfo['type'] + '-${version}.pkg'

    # Package ID
    pkgid = launchdinfo['name'].split('.')
    pkgid.insert(-1, 'launch' + launchdinfo['type'])
    launchdinfo['pkgid'] = '.'.join(pkgid)

    return launchdinfo


def generate_postinstall_script(launchdinfo, pkg_directory):
    """Generate pkg postinstall script"""
    if launchdinfo['type'] == 'agent':
        postinstall_load_command = [
            'consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`\n',
            '\n',
            'if [ "$consoleuser" -eq 0 ]\n',
            'then\n',
            '    exit 0\n',
            'fi\n',
            '\n',
            '/bin/launchctl bootstrap gui/$consoleuser ',
            launchdinfo['location'],
            '\n'
        ]
    else:
        postinstall_load_command = [
            '/bin/launchctl load ',
            launchdinfo['location'],
            '\n'
        ]

    postinstall_script = [
        '#!/bin/sh\n',
        '\n',
        '#\n',
        '#  Postinstall script for ',
        launchdinfo['pkgid'],
        '\n',
        '#\n',
        '#\n',
        '#  Generated using the buildLaunchDPkg\n',
        '#  tool created by Jacob F. Grant\n',
        '#\n',
        '#  https://github.com/jacobfgrant/mac-admin\n',
        '#\n',
        '#  Created: ',
        time.strftime("%x"),
        '\n',
        '#\n',
        '\n',
        '\n',
        'chmod 644 ',
        launchdinfo['location'],
        '\n',
        'chown root:wheel ',
        launchdinfo['location'],
        '\n',
        '\n',
        '\n'
    ] +  postinstall_load_command

    output = os.path.join(pkg_directory, 'scripts', 'postinstall')

    with open(output, 'a') as script_file:
        for line in postinstall_script:
            script_file.write(line)


def generate_buildinfo_plist(launchdinfo, pkg_directory):
    """Generate pkg build-info.plist"""
    buildinfo = {
        'postinstall_action': 'none',
        'name': launchdinfo['pkgname'],
        'distribution_style': False,
        'install_location': '/',
        'version': launchdinfo['version'],
        'identifier': launchdinfo['pkgid']
    }
    output = os.path.join(pkg_directory, 'build-info.plist')

    plistlib.writePlist(buildinfo, output)


def create_pkg_directory(launchdinfo):
    """Creat package directory"""
    pkg_directory = (
        launchdinfo['name'].split('.')[-1] +
        '-' +
        ''.join(["%s" % randint(0, 9) for num in range(0, 5)])
    )
    pkg_directory = os.path.join('/tmp', pkg_directory)

    if os.path.exists(pkg_directory):
        create_pkg_directory(launchdinfo)
    else:
        os.makedirs(pkg_directory)
        os.makedirs(os.path.join(pkg_directory, 'scripts'))
        os.makedirs(os.path.join(
            pkg_directory,
            'payload',
            os.path.dirname(launchdinfo['location']).lstrip('/'))
        )

    return pkg_directory


def build_pkg(pkg_directory, quiet):
    """Build pkg with munkipkg"""
    if quiet:
        return subprocess.call(['munkipkg', pkg_directory, '--quiet'])
    else:
        return subprocess.call(['munkipkg', pkg_directory])


def main():
    """Main function"""
    # Parse script arguments
    main_parser = argparse.ArgumentParser(
        description='Packages a launchd LaunchDaemon/LaunchAgent into a pkg file using the munkipkg tool.')
    main_parser.add_argument(
        '-q',
        '--quiet',
        action="store_true",
        help="Suppress normal output messages. Errors will still be printed to stderr.",
    )
    main_parser.add_argument(
        '-p',
        '--plist',
        help="The .plist file constituting the LaunchDaemon/LaunchAgent.",
        required=True
    )
    main_parser.add_argument(
        '-t',
        '--type',
        choices=['agent', 'daemon'],
        help="Specifies whether the package should install a LaunchAgent or LaunchDaemon (defaults to LaunchDaemon).",
        default='daemon'
    )
    main_parser.add_argument(
        '-v',
        '--version',
        help="The package version number (defaults to 1.0).",
        default='1.0'
    )
    main_parser.add_argument(
        '-o',
        '--output',
        help="Output location (defaults to current directory).",
        default='.'
    )
    args = main_parser.parse_args()
    quiet = args.quiet
    output = args.output

    launchdinfo = gather_launchdinfo(args)

    pkg_directory = create_pkg_directory(launchdinfo)
    generate_postinstall_script(launchdinfo, pkg_directory)
    generate_buildinfo_plist(launchdinfo, pkg_directory)
    shutil.copy(
        launchdinfo['plist'],
        os.path.join(pkg_directory, 'payload', os.path.dirname(launchdinfo['location']).lstrip('/'))
    )
    build_pkg(pkg_directory, quiet)

    shutil.copy(
        os.path.join(
            pkg_directory,
            'build',
            launchdinfo['pkgname'].replace('${version}', launchdinfo['version'])
        ),
        output
    )


if __name__ == "__main__":
    main()
