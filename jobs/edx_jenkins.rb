require 'open-uri'
require 'openssl'
require 'json'

current_status = nil
SCHEDULER.every '10s', :first_in => 0 do
    last_status = current_status

    build_uri = JENKINS_JOB_URL + "/lastBuild/api/json"

    # Once SSL certificates are set up correctly, we can remove the :ssl_verify_mode option
    data = open(build_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    build_info = JSON.parse(data)
    current_status = build_info["result"]
    if build_info["building"] == true
        current_status = "BUILDING"
    end
    send_event("jenkins_deploy_status", {
        resultText: current_status,
        fullDisplayName: build_info["fullDisplayName"],
        currentResult: current_status,
        lastResult: last_status,
        number: build_info["number"],
        url: build_info["url"],
        timestamp: build_info["timestamp"] })
end
