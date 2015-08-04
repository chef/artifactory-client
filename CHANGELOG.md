Artifactory Client CHANGELOG
============================
This file is used to document the changes between releases of the Artifactory
Ruby client.

v2.3.0 (08-04-2015)
-------------------
- Support for Build endpoints

v2.2.1 (12-16-2014)
-------------------
- provide data to post in `Artifact#copy_or_move`
- pass correct variable to redirect request in `Client#request`
- use CGI escape to encode data values
- when checksums are available, upload using the checksum headers.

v2.2.0 (11-20-2014)
-------------------
- Add artifact usage search
- Add artifact creation search
- Add support for configuring permission targets

v2.1.3 (08-29-2014)
-------------------
- CGI escape matrix properties

v2.1.2 (08-26-2014)
-------------------
- Use the proper REST verbs on various resources to prevent a bug

v2.1.1 (08-25-2014)
-------------------
- Use the proper name for POM consistency checks
- Use the proper name for checksum policies
- Use the proper name for max unique snapshots

**Other Changes**
- Improve integration test coverage
- Enable running integration tests in `Rakefile`

v2.1.0 (08-21-2014)
-------------------
- Add `Content-Size` header
- Expose `read_timeout` as a configurable (defaulting to 120 seconds)

v2.0.0 (07-15-2014)
-------------------
**Breaking Changes**
- Change the airity of uploading an Artifact
- Automatically upload checksum files during Artifact upload

**Other Changes**
- Bump to RSpec 3
- Add support for configuring the Backup resource
- Add support for configuring the LDAPSetting resource
- Add support for configuring the MailServer resource
- Add support for configuring the URLBase resource
- Set `Transfer-Encoding` to "chunked"
- Do not swallow returned errors from the server

v1.2.0 (2014-06-02)
-------------------
- Change the airty of Repository#find to align with other resources
- Add the ability to save/create repositories
- Remove i18n
- Make proxy configuration more verbose
- Remove HTTPClient in favor of raw Net::HTTP
- Add custom SSL configuration options
- Make Configurable#proxy_port a string because #ocd
- Allow file uploads
- Return an Artifact object after uploading
- Allow repositories to be deleted
- Add required attribute for repository layout
- Move upload method from Repository to Artifact
- Implement Repository.upload via Artifact.upload
- Move to_matrix_properties method to base class
- Add the ability to list/find repository layouts from xml configuration
- Specify content-type for updating config

v1.1.0 (2014-02-11)
-------------------
- Add support for group resources
- Add support for user resources

v1.0.0 (2014-02-10)
-------------------
- Initial release
