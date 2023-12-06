# okta-api-things
getting me tentacles all wet
---

## What does this do?

The scripts here are simple bash scripts, designed to talk to your Okta tenancy and pull useful information that can be used as general
backups and disaster/ransomware recovery. My personal plan for use is to run these as cron tasks in a VM on a daily schedule, and store the backup files outside normal corporate infrastructure.

## How to use

You'll need to generate a superadmin API token in your Okta admin panel, then add that to your keychain/keystore/etc. That's pretty much it.

## Future

I plan on adding various extra bits and pieces as the need arises.