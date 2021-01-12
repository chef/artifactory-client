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
    attribute :rclass, 'local'
    attribute :archive_browsing_enabled
    attribute :blacked_out, false
    attribute :block_pushing_schema1
    attribute :calculate_yum_metadata
    attribute :cdn_redirect
    attribute :checksum_policy_type
    attribute :debian_trivial_layout
    attribute :docker_api_version, 'V2'
    attribute :download_redirect, false
    attribute :enable_file_lists_indexing, false
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :key_pair_ref
    attribute :max_unique_snapshots, 0
    attribute :max_unique_tags, 0
    attribute :optional_index_compression_formats
    attribute :property_sets
    attribute :snapshot_version_behavior, 'non-unique'
    attribute :suppress_pom_consistency_checks, false
    attribute :xray_index, false
    attribute :yum_root_depth

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
