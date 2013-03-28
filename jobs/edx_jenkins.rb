require 'net/http'
require 'json'

JENKINS_BASE_URL = 'jenkins.edx.org'
JENKINS_PORT = 8080

# the key of this mapping must be a unique identifier for your job, the according value must be the name that is specified in jenkins
job_mapping = {
  'jenkins_status' => 'edx-deploy-branch-tests'
}

job_mapping.each do |title, jenkins_project|
    current_status = nil
    SCHEDULER.every '10s', :first_in => 0 do
        last_status = current_status
        http = Net::HTTP.new(JENKINS_BASE_URL, JENKINS_PORT)
        response = http.request(Net::HTTP::Get.new("/job/#{jenkins_project}/lastBuild/api/json"))
        build_info = JSON.parse(response.body)
        current_status = build_info["result"]
        send_event(title, { 
            resultText: current_status,
            fullDisplayName: build_info["fullDisplayName"],
            currentResult: current_status, 
            lastResult: last_status, 
            number: build_info["number"], 
            url: build_info["url"],
            timestamp: build_info["timestamp"] })
    end
end