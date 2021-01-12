#
# Copyright 2014-2018 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Artifactory
  class Resource::RemoteRepository < Resource::Repository
    attribute :rclass, 'remote'
    attribute :allow_any_host_auth
    attribute :assumed_offline_period_secs
    attribute :blacked_out
    attribute :block_mismatching_mime_types
    attribute :block_pushing_schema1
    attribute :bower_registry_url
    attribute :bypass_head_requests
    attribute :cdn_redirect
    attribute :client_tls_certificate
    attribute :composer_registry_url
    attribute :content_synchronisation
    attribute :download_context_path
    attribute :download_redirect
    attribute :enable_cookie_management
    attribute :enable_token_authentication
    attribute :external_dependencies_enabled
    attribute :external_dependencies_patterns
    attribute :feed_context_path
    attribute :fetch_jars_eagerly
    attribute :fetch_sources_eagerly
    attribute :handle_releases
    attribute :handle_snapshots
    attribute :hard_fail
    attribute :local_address
    attribute :max_unique_snapshots
    attribute :missed_retrieval_cache_period_secs
    attribute :offline
    attribute :password
    attribute :property_sets
    attribute :proxy
    attribute :py_pi_registry_url
    attribute :remote_repo_checksum_policy_type
    attribute :retrieval_cache_period_secs
    attribute :share_configuration
    attribute :socket_timeout_millis
    attribute :store_artifacts_locally
    attribute :suppress_pom_consistency_checks
    attribute :synchronize_properties
    attribute :unused_artifacts_cleanup_period_hours
    attribute :url, -> { raise "You MUST set required attribute: url" }
    attribute :username
    attribute :v3_feed_url
    attribute :vcs_git_download_url
    attribute :vcs_git_provider
    attribute :vcs_type
    attribute :xray_index

    #
    # Content-Type for repository
    #
    # @return [String]
    #
    def content_type
      "application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json"
    end
  end
end
