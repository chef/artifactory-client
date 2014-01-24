require 'sinatra/base'

module Artifactory
  #
  # An in-memory, fully-API compliant Artifactory server. The data is all
  # fake, but it is based off of real responses from the Artifactory server.
  #
  class APIServer < Sinatra::Base
    require_relative 'api_server/artifact_endpoints'
    require_relative 'api_server/status_endpoints'
    require_relative 'api_server/system_endpoints'

    register APIServer::ArtifactEndpoints
    register APIServer::StatusEndpoints
    register APIServer::SystemEndpoints
  end
end
