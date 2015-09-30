require 'artifactory/resources/repository_base'

module Artifactory
  class Resource::VirtualRepository < Resource::Base
    include Resource::RepositoryBase

    attribute :rclass, 'virtual'
    attribute :repositories, []
    attribute :package_type, 'maven'
    attribute :description
    attribute :notes
    attribute :includes_pattern, '**/*'
    attribute :excludes_pattern, ''
    attribute :debian_trivial_layout, false
    attribute :artifactory_requests_can_retrieve_remote_artifacts, false
    attribute :key_pair
    attribute :pom_repository_references_cleanup_policy, 'discard_active_reference'

    def content_type
      'application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json'
    end
  end
end