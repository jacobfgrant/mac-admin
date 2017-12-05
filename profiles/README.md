## Profiles

Configuration profiles (.mobileconfig files) used to configure macOS and iOS.


* **AppleSoftwareUpdate** – Disables Mac App Store automatic updates (useful when performing Apple updates through munki)

* **ChromeDefaultBrowser** – Sets Google Chrome as the default web browser (does not appear to completely work in 10.12+)

* **ChromeExtensionPolicy** – Sets policies governing installing Google Chrome extensions

* **ChromeInstallExtensions** – Installs Google Chrome extensions (uBlock Origin, HTTPS Everywhere, and LastPass)

* **ChromeManagedBookmarks** – Adds managed bookmarks to Google Chrome

* **ChromePreferences** – Configures Google Chrome preferences

* **ChromeURLBlacklist** – Blacklists URLs from Google Chrome

* **DiagnosticSettings** – Disables sending diagnostics and usage data to Apple and app developers

* **DisableAppResume** – Disables automatic app resume upon login on macOS

* **DisableSiri** – Disables Siri

* **DisableWifi** – Disables Wifi (Note: requires removal and restart to re-enable)

* **DisableiCloudDesktopDocuments** – Disables Desktop and Documents folder iCloud sync

* **FastUserSwitching** – Enables fast user switching

* **Finder** – Configures settings for macOS Finder

* **ManagedInstalls** – Configures the Managed Installs preferences for munki (Note: all preferences are present and set to either empty or default values. It is necessary to set or remove them.)

* **Munkireport** – Sets [client passphrase](https://github.com/munkireport/munkireport-php/wiki/Client-passphrase) for [MunkiReport-PHP](https://github.com/munkireport/munkireport-php) clients

* **Office365** – Disables various telemetry, macros, and various other settings for Office 365 services

* **Office365Excel** – Disables telemetry and first-run setup for Microsoft Excel

* **Office365OneDrive** – Configures OneDrive sync default settings

* **Office365OneNote** – Disables telemetry and first-run setup for Microsoft OneNote

* **Office365Outlook** – Disables telemetry and first-run setup for Microsoft Outlook

* **Office365PowerPoint** – Disables telemetry and first-run setup for Microsoft PowerPoint

* **Office365Skype** – Enables silent upgrades for Skype and disables associated notifications

* **Office365Word** – Disables telemetry and first-run setup for Microsoft Word

* **Safari** – Configures Safari preferences

* **Sal** – Configures settings for [Sal](https://github.com/salopensource/sal) client

* **SkipSiriSetup** – Skips Siri panel in Setup Assistant

* **SkipiCloudSetup** – Skip iCloud account setup panel in Setup Assistant
