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
  class Resource::LocalRepository < Resource::Repository
    attribute :allow_any_host_auth
    attribute :archive_browsing_enabled
    attribute :artifactory_requests_can_retrieve_remote_artifacts
    attribute :assumed_offline_period_secs
    attribute :blacked_out, false
    attribute :block_mismatching_mime_types
    attribute :block_pushing_schema1
    attribute :bower_registry_url
    attribute :bypass_head_requests
    attribute :calculate_yum_metadata, false
    attribute :cdn_redirect
    attribute :checksum_policy_type, "client-checksums"
    attribute :client_tls_certificate, ""
    attribute :composer_registry_url
    attribute :content_synchronisation
    attribute :debian_trivial_layout, false
    attribute :default_deployment_repo
    attribute :description
    attribute :docker_api_version, 'V2'
    attribute :download_context_path
    attribute :download_redirect, false
    attribute :enable_cookie_management
    attribute :enable_file_lists_indexing, "false"
    attribute :enable_token_authentication
    attribute :excludes_pattern, ""
    attribute :external_dependencies_enabled, false
    attribute :external_dependencies_patterns
    attribute :external_dependencies_remote_repo
    attribute :feed_context_path
    attribute :fetch_jars_eagerly
    attribute :fetch_sources_eagerly
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :hard_fail
    attribute :includes_pattern, "**/*"
    attribute :key, -> { raise "Key is missing!" }
    attribute :key_pair
    attribute :key_pair_ref
    attribute :local_address
    attribute :max_unique_snapshots, 0
    attribute :max_unique_tags, 0
    attribute :missed_retrieval_cache_period_secs
    attribute :notes
    attribute :offline
    attribute :optional_index_compression_formats
    attribute :package_type, "generic"
    attribute :password
    attribute :pom_repository_references_cleanup_policy
    attribute :property_sets, []
    attribute :proxy
    attribute :py_pi_registry_url
    attribute :rclass, "local"
    attribute :remote_repo_checksum_policy_type
    attribute :repo_layout_ref, "maven-2-default"
    attribute :repositories, []
    attribute :retrieval_cache_period_secs
    attribute :share_configuration
    attribute :snapshot_version_behavior, "non-unique"
    attribute :socket_timeout_millis
    attribute :store_artifacts_locally
    attribute :suppress_pom_consistency_checks, false
    attribute :synchronize_properties
    attribute :unused_artifacts_cleanup_period_hours
    attribute :url, ""
    attribute :username
    attribute :v3_feed_url
    attribute :vcs_git_download_url
    attribute :vcs_git_provider
    attribute :vcs_type
    attribute :xray_index, false
    attribute :yum_root_depth, 0

    #
    # Content-Type for repository
    #
    # @return [String]
    #
    def content_type
      "application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json"
    end
  end
end
