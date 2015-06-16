#
# Copyright 2014 Chef Software, Inc.
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
  class Resource::Build < Resource::Base
    class << self
      #
      # Search for all builds in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Build>]
      #   the list of builds
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/build')['builds']
      rescue Error::HTTPError => e
        # Artifactory returns a 404 instead of an empty list when there are no
        # builds. Whoever decided that was a good idea clearly doesn't
        # understand the point of REST interfaces...
        raise unless e.code == 404
        []
      end
    end
  end
end
