module Artifactory
  class Resource::RemoteRepository < Resource::Base
    attribute :key, ->{ raise ArgumentError('key is required') }
    attribute :rclass, 'remote'
    attribute :package_type, 'maven'
    attribute :url, ->{ raise ArgumentError('url is required') }
    attribute :username
    attribute :password
    attribute :proxy
    attribute :description
    attribute :notes
    attribute :includes_pattern, '**/*'
    attribute :excludes_pattern, ''
    attribute :remote_repo_checksum_policy_type, 'generate-if-absent'
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :max_unique_snapshots, 0
    attribute :suppress_pom_consistency_checks, false
    attribute :hard_fail, false
    attribute :offline, false
    attribute :blacked_out, false
    attribute :store_artifacts_locally, true
    attribute :socket_timeout_millis, 15000
    attribute :local_address, '212.150.139.167'
    attribute :retrieval_cache_period_secs, 43200
    attribute :failed_retrieval_cache_period_secs, 30
    attribute :missed_retrieval_cache_period_secs, 7200
    attribute :unused_artifacts_cleanup_enabled, false
    attribute :unused_artifacts_cleanup_period_hours, 0
    attribute :fetch_jars_eagerly, false
    attribute :fetch_sources_eagerly, false
    attribute :share_configuration, false
    attribute :synchronize_properties, false
    attribute :property_sets, []
    attribute :allow_any_host_auth, false
    attribute :enable_cookie_management, false
    attribute :bower_registry_url, 'https://bower.herokuapp.com'
    attribute :vcs_type, 'GIT'
    attribute :vcs_git_provider, 'GITHUB'
    attribute :vcs_git_download_url, ''

    def content_type
      'application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json'
    end
  end
end