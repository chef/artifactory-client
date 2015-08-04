require 'sinatra/base'

module Artifactory
  #
  # An in-memory, fully-API compliant Artifactory server. The data is all
  # fake, but it is based off of real responses from the Artifactory server.
  #
  class APIServer < Sinatra::Base
    require_relative 'api_server/artifact_endpoints'
    require_relative 'api_server/build_component_endpoints'
    require_relative 'api_server/build_endpoints'
    require_relative 'api_server/group_endpoints'
    require_relative 'api_server/repository_endpoints'
    require_relative 'api_server/permission_target_endpoints'
    require_relative 'api_server/status_endpoints'
    require_relative 'api_server/system_endpoints'
    require_relative 'api_server/user_endpoints'

    register APIServer::ArtifactEndpoints
    register APIServer::BuildComponentEndpoints
    register APIServer::BuildEndpoints
    register APIServer::GroupEndpoints
    register APIServer::PermissionTargetEndpoints
    register APIServer::RepositoryEndpoints
    register APIServer::StatusEndpoints
    register APIServer::SystemEndpoints
    register APIServer::UserEndpoints

    private

    #
    # This server's URL, returned as a {Pathname} for easy joining.
    #
    # @example Construct a server url
    #   server_url.join('libs-release-local', 'artifact.deb')
    #
    # @return [Pathname]
    #
    def server_url
      @server_url ||= begin
        scheme  = request.env['rack.url_scheme']
        address = request.env['SERVER_NAME']
        port    = request.env['SERVER_PORT']

        Pathname.new("#{scheme}://#{address}:#{port}")
      end
    end
  end
end
