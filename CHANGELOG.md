Artifactory Client CHANGELOG
============================
This file is used to document the changes between releases of the Artifactory
Ruby client.

<!-- latest_release -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v3.0.17](https://github.com/chef/artifactory-client/tree/v3.0.17) (2024-03-04)

#### Merged Pull Requests
- Fix verify pipeline [#145](https://github.com/chef/artifactory-client/pull/145) ([jayashrig158](https://github.com/jayashrig158))
- Upgrade to GitHub-native Dependabot [#140](https://github.com/chef/artifactory-client/pull/140) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
<!-- latest_stable_release -->

## [v3.0.5](https://github.com/chef/artifactory-client/tree/v3.0.5) (2024-03-04)

## [v3.0.15](https://github.com/chef/artifactory-client/tree/v3.0.15) (2020-05-29)

#### Merged Pull Requests
- Follow redirects in client.get [#132](https://github.com/chef/artifactory-client/pull/132) ([jgitlin-p21](https://github.com/jgitlin-p21))

## [v3.0.13](https://github.com/chef/artifactory-client/tree/v3.0.13) (2020-05-15)

#### Merged Pull Requests
- Update Rubocop and fix deprecated URI methods [#130](https://github.com/chef/artifactory-client/pull/130) ([tduffield](https://github.com/tduffield))

## [v3.0.12](https://github.com/chef/artifactory-client/tree/v3.0.12) (2019-12-31)

#### Merged Pull Requests
- Update rspec-mocks requirement from 3.4.0 to 3.9.0 [#121](https://github.com/chef/artifactory-client/pull/121) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
- Update webmock requirement from ~&gt; 2.3 to ~&gt; 3.7 [#120](https://github.com/chef/artifactory-client/pull/120) ([dependabot-preview[bot]](https://github.com/dependabot-preview[bot]))
- Update README.md [#117](https://github.com/chef/artifactory-client/pull/117) ([johnlabarge](https://github.com/johnlabarge))
- Use require_relative for link and remove appveyor links [#123](https://github.com/chef/artifactory-client/pull/123) ([tas50](https://github.com/tas50))
- Test on Ruby 2.7 and use buster containers [#124](https://github.com/chef/artifactory-client/pull/124) ([tas50](https://github.com/tas50))
- Resolve all chefstyle warnings [#125](https://github.com/chef/artifactory-client/pull/125) ([tas50](https://github.com/tas50))
- Remove rainbow test constraint in the gemfile [#126](https://github.com/chef/artifactory-client/pull/126) ([tas50](https://github.com/tas50))

## [v3.0.5](https://github.com/chef/artifactory-client/tree/v3.0.5) (2019-07-25)

#### Merged Pull Requests
- Added empty string if success response body is nil [#99](https://github.com/chef/artifactory-client/pull/99) ([APayden](https://github.com/APayden))
- Setup PR verification with Buildkite [#113](https://github.com/chef/artifactory-client/pull/113) ([tas50](https://github.com/tas50))
- Remove Travis CI pull request testing [#114](https://github.com/chef/artifactory-client/pull/114) ([tas50](https://github.com/tas50))
- Replace AppVeyor with Buildkite as well [#115](https://github.com/chef/artifactory-client/pull/115) ([tas50](https://github.com/tas50))
- Add support for managing SSL/TLS certificates [#110](https://github.com/chef/artifactory-client/pull/110) ([bodgit](https://github.com/bodgit))

## [v3.0.0](https://github.com/chef/artifactory-client/tree/v3.0.0) (2018-12-12)

#### Merged Pull Requests
- Require Ruby 2.3+ and update Travis / Appveyor config [#101](https://github.com/chef/artifactory-client/pull/101) ([tas50](https://github.com/tas50))
- Add code of conduct and a contributing doc [#103](https://github.com/chef/artifactory-client/pull/103) ([tas50](https://github.com/tas50))
- Update the maintainer [#104](https://github.com/chef/artifactory-client/pull/104) ([tas50](https://github.com/tas50))
- Don&#39;t ship the test / development files in the gem artifact [#105](https://github.com/chef/artifactory-client/pull/105) ([tas50](https://github.com/tas50))
- Bump copyrights and bump to 3.0 [#106](https://github.com/chef/artifactory-client/pull/106) ([tas50](https://github.com/tas50))

v2.8.2 (06-14-2017)
-------------------
- Properly parse empty response bodies

v2.8.1 (03-21-2017)
-------------------
- Allow downloading of large files. Fixes #83.

v2.8.0 (03-17-2017)
-------------------
- Include statuses in Build resource

v2.7.0 (02-21-2017)
-------------------
- Include statuses in Build resource

v2.6.0 (02-02-2017)
-------------------
- Add API Key authentication
- Add new Ruby versions to test matrix
- Add ChefStyle for linting

v2.5.2 (01-27-2017)
-------------------
- Update tests to run properly on Windows
- Begin testing PRs with Appveyor
- Ensure URI from artifacts are escaped

v2.5.1 (11-10-2016)
-------------------
- Ensure `Artifact#Upload_from_archive` returns empty response
- Additional test coverage

v2.5.0 (09-15-2016)
-------------------
- Add support for extended YUM repo attributes

v2.4.0 (09-13-2016)
-------------------
- Coerce `ARTIFACTORY_READ_TIMEOUT` value to integer
- Add url attribute to support remote repositories

v2.3.3 (06-27-2016)
-------------------
- Artifactory 4 requires setting package type during repository creation

v2.3.2 (11-20-2015)
-------------------
- Fix embedded requests when endpoint has a non-empty path

v2.3.1 (11-13-2015)
-------------------
- Ensure embedded requests respect configured settings

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