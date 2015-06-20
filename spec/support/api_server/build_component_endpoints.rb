module Artifactory
  module APIServer::BuildComponentEndpoints
    def self.registered(app)
      app.get('/api/build') do
        content_type 'application/vnd.org.jfrog.build.Builds+json'
        JSON.fast_generate(
          'uri'    => server_url.join('/api/build'),
          'builds' => [
            {
              'uri'         => '/wicket',
              'lastStarted' => '2015-06-19T20:13:20.222Z',
            },
            {
              'uri'         => '/jackrabbit',
              'lastStarted' => '2015-06-20T20:13:20.333Z',
            }
          ]
        )
      end

      app.post('/api/build/rename/:name') do
        content_type 'text/plain'
        body "Build renaming of '#{params['name']}' to '#{params['to']}' was successfully started."
      end

      app.delete('/api/build/:name') do
        content_type 'text/plain'

        if params['deleteAll']
          body "All '#{params['name']}' builds have been deleted successfully."
        elsif params['buildNumbers'].nil?
          status 400
          body 'Please provide at least one build number to delete.'
        else
          message = params['buildNumbers'].split(',').map do |n|
            "#{params['name']}##{n}"
          end.join(', ')

          body "The following builds has been deleted successfully: #{message}."
        end
      end
    end
  end
end
