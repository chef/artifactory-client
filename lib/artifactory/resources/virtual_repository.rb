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
  class Resource::VirtualRepository < Resource::Repository
    attribute :rclass, "virtual"
    attribute :artifactory_requests_can_retrieve_remote_artifacts
    attribute :debian_trivial_layout
    attribute :default_deployment_repo
    attribute :external_dependencies_enabled
    attribute :external_dependencies_patterns
    attribute :external_dependencies_remote_repo
    attribute :key_pair
    attribute :key_pair_ref
    attribute :pom_repository_references_cleanup_policy, "discard_active_reference"
    attribute :repositories, []

    #
    # Content-Type for repository
    #
    # @return [String]
    #
    def content_type
      "application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json"
    end
  end
end
