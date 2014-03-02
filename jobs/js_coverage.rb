require 'open-uri'
require 'openssl'
require 'json'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the number of the last stable build
    last_build_uri = JENKINS_JOB_URL + '/lastStableBuild/buildNumber'

    # Once SSL certificates are set up correctly, we can remove the :ssl_verify_mode option
    response = open(last_build_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read
    last_build_num = response.to_i

    # Retrieve the coverage info as JSON
    coverage_uri = JENKINS_JOB_URL + "/SHARD=1,TEST_SUITE=unit/#{last_build_num}/cobertura/javascript/api/json?depth=2"
    coverage_data = open(coverage_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    # Parse the JSON
    json = JSON.parse(coverage_data)
    result_elements = json["results"]["elements"]

    line_coverage = nil
    result_elements.each do |result|
        # Result is a hash with keys 'ratio' and 'name'
        # We're looking for the name 'Lines'
        if result['name'] == 'Lines'
            line_coverage = result['ratio'].to_i
        end
    end

    send_event('js_coverage',   { value: line_coverage })
end
