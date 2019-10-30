## Release 0.2.0

### Bug fixes

* **Expand `dir` path relative to Boltdir** ([#1162](https://github.com/puppetlabs/bolt/issues/1162))

  The `dir` option will now be expanded relative to the active Boltdir the user is running bolt with, instead of the current working directory they ran Bolt from. This is part of standardizing all configurable paths in Bolt to be relative to the Boltdir.

## Release 0.1.0

This is the initial release.
