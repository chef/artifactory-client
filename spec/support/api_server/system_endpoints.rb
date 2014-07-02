module Artifactory
  module APIServer::SystemEndpoints
    def self.registered(app)
      app.get('/api/system') do
        'This is some serious system info right here'
      end

      app.get('/api/system/ping') do
        'OK'
      end

      app.get('/api/system/configuration') do
        content_type 'application/xml'
        <<-EOH.gsub(/^ {10}/, '')
          <?xml version='1.0' encoding='UTF-8' standalone='yes'?>
          <config xsi:schemaLocation='http://www.jfrog.org/xsd/artifactory-v1_5_3.xsd'
                  xmlns='http://artifactory.jfrog.org/xsd/1.5.3'
                  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <offlineMode>false</offlineMode>
            <repoLayouts>
              <repoLayout>
                <name>maven-2-default</name>
                <artifactPathPattern>[orgPath]/[module]/[baseRev](-[folderItegRev])/[module]-[baseRev](-[fileItegRev])(-[classifier]).[ext]</artifactPathPattern>
                <distinctiveDescriptorPathPattern>true</distinctiveDescriptorPathPattern>
                <descriptorPathPattern>[orgPath]/[module]/[baseRev](-[folderItegRev])/[module]-[baseRev](-[fileItegRev])(-[classifier]).pom</descriptorPathPattern>
                <folderIntegrationRevisionRegExp>SNAPSHOT</folderIntegrationRevisionRegExp>
                <fileIntegrationRevisionRegExp>SNAPSHOT|(?:(?:[0-9]{8}.[0-9]{6})-(?:[0-9]+))</fileIntegrationRevisionRegExp>
              </repoLayout>
              <repoLayout>
                <name>gradle-default</name>
                <artifactPathPattern>[orgPath]/[module]/[baseRev](-[folderItegRev])/[module]-[baseRev](-[fileItegRev])(-[classifier]).[ext]</artifactPathPattern>
                <distinctiveDescriptorPathPattern>true</distinctiveDescriptorPathPattern>
                <descriptorPathPattern>[orgPath]/[module]/[baseRev](-[folderItegRev])/[module]-[baseRev](-[fileItegRev])(-[classifier]).pom</descriptorPathPattern>
                <folderIntegrationRevisionRegExp>SNAPSHOT</folderIntegrationRevisionRegExp>
                <fileIntegrationRevisionRegExp>SNAPSHOT|(?:(?:[0-9]{8}.[0-9]{6})-(?:[0-9]+))</fileIntegrationRevisionRegExp>
              </repoLayout>
            </repoLayouts>
            <urlBase>http://33.33.33.20/artifactory</urlBase>
            <mailServer>
              <enabled>true</enabled>
              <host>smtp.gmail.com</host>
              <port>25</port>
              <username>us@example.com</username>
              <password>ihopethisisnotyourpassword</password>
              <from>artifactory@example.com</from>
              <subjectPrefix>[Artifactory]</subjectPrefix>
              <tls>true</tls>
              <ssl>false</ssl>
              <artifactoryUrl>http://33.33.33.20/artifactory</artifactoryUrl>
            </mailServer>
            <security>
              <ldapSettings>
                <ldapSetting>
                  <key>example-ldap</key>
                  <enabled>true</enabled>
                  <ldapUrl>ldap://localhost/DC=examplecorp,DC=com</ldapUrl>
                  <search>
                    <searchFilter>sAMAccountName={0}</searchFilter>
                    <searchBase>OU=Domain Users</searchBase>
                    <searchSubTree>true</searchSubTree>
                    <managerDn>CN=ldapbind,OU=Employees,OU=Domain Users,DC=examplecorp,DC=com</managerDn>
                    <managerPassword>ldappassword</managerPassword>
                  </search>
                  <autoCreateUser>false</autoCreateUser>
                  <emailAttribute>mail</emailAttribute>
                </ldapSetting>
              </ldapSettings>
            </security>
            <backups>
              <backup>
                <key>backup-daily</key>
                <enabled>true</enabled>
                <cronExp>0 0 2 ? * MON-FRI</cronExp>
                <retentionPeriodHours>0</retentionPeriodHours>
                <createArchive>false</createArchive>
                <excludedRepositories/>
                <sendMailOnError>true</sendMailOnError>
                <excludeBuilds>false</excludeBuilds>
             </backup>
           </backups> 
         </config>
        EOH
      end

      app.post('/api/system/configuration') do
        # Just echo the response we got back, since it seems that's what a real
        # Artifactory server does...
        request.body.read
      end

      app.get('/api/system/version') do
        content_type 'application/vnd.org.jfrog.artifactory.system.Version+json'
        JSON.generate({
          'version' => '3.1.0',
          'revision' => '30062',
          'addons' => [
            'ldap',
            'license',
            'yum'
          ]
        })
      end
    end
  end
end
