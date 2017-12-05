## Packages

Packages (.pkg files) to be built using Greg Neagle's [munkipkg tool](https://github.com/munki/munki-pkg).


* **ard-setup** – Runs a post-install script to enable ARD (Remote Management) for the specified user(s)

* **chrome-enable-autoupdates** – Installs [Hannes Juutilainen's](https://github.com/hjuutilainen) [chrome-enable-autoupdates](https://github.com/hjuutilainen/adminscripts/blob/master/chrome-enable-autoupdates.py) script in the `outset/login-privileged-once` folder to ensure Google Chrome autoupdates for all users (requires [outset](https://github.com/chilcote/outset))

* **chrome-extension-https-everywhere** – Installs the HTTPS Everywhere Chrome extension (requires [outset](https://github.com/chilcote/outset)) [DEPRECATED]

* **chrome-extension-lastpass** – Installs the LastPass Chrome extension (requires [outset](https://github.com/chilcote/outset)) [DEPRECATED]

* **chrome-extension-ublock-origin** – Installs the uBlock Origin Chrome extension (requires [outset](https://github.com/chilcote/outset)) [DEPRECATED]

* **chrome-first-run** – Installs a script in `outset/login-every` to bypass Google Chrome's first-run setup (requires [outset](https://github.com/chilcote/outset))

* **cloudfront-middleware** – Installs [Aaron Burchfield's](https://github.com/AaronBurchfield) AWS [CloudFront Middleware](https://github.com/AaronBurchfield/CloudFront-Middleware) script for munki, along with the necessary preference file and certificate, to allow munki to be used with an AWS CloudFront distribution with restrictions enabled.

* **dock-setup** – Installs a script in `outset/login-once` to configure the Dock (requires [dockutil](https://github.com/kcrawford/dockutil), [outset](https://github.com/chilcote/outset))

* **duti** – Installs the compiled [duti](https://github.com/moretension/duti) binary and man page from homebrew (v1.5.3)

* **finder-setup** – Installs a script in `outset/login-once` to configure the Finder sidebar (requires [mysides](https://github.com/mosen/mysides), [outset](https://github.com/chilcote/outset))

* **firewall-setup** – Runs a post-install script to enable the MacOS firewall and allow built-in and signed software to recieve connections (10.12 and up)

* **msoffice-setup-user** – Installs a script in `outset/login-every` to personalize Microsoft Office 2016 for the user (requires [outset](https://github.com/chilcote/outset))

* **munki-bootstrap** – Installs a script to `outset/boot-once` and runs a post-install script to bootstrap munki after re-imaging a Mac (requires [outset](https://github.com/chilcote/outset))

* **munki-startup** – Installs a script in `outset/login-every` to run munki at the login screen on startup (requires [outset](https://github.com/chilcote/outset))

* **open-onedrive** – Installs a script in `outset/login-every` to open the Microsoft OneDrive app at login if installed and the user has a OneDrive folder in their home or Documents folder (requires [outset](https://github.com/chilcote/outset))

* **set-outlook-default** – Installs a script in `outset/login-every` to set Microsoft Outlook as the default mail client (requires [duti](https://github.com/moretension/duti), [outset](https://github.com/chilcote/outset))
