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
    attribute :archive_browsing_enabled
    attribute :calculate_yum_metadata
    attribute :checksum_policy_type
    attribute :debian_trivial_layout
    attribute :docker_api_version
    attribute :enable_file_lists_indexing
    attribute :key_pair_ref
    attribute :max_unique_tags
    attribute :optional_index_compression_formats
    attribute :snapshot_version_behavior
    attribute :yum_root_depth

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
