require "net/http"
require "json"

host = 'jenkins.edx.org'
port = '8080'
http = Net::HTTP.new(host, port)


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the number of the last stable build
    last_build_uri = '/job/edx-deploy-branch-tests/lastStableBuild/buildNumber'
    response = http.request(Net::HTTP::Get.new(last_build_uri))
    last_build_num = response.body.to_i

    # Retrieve the coverage info as JSON
    coverage_uri = "/job/edx-deploy-branch-tests/#{last_build_num}/cobertura/javascript/api/json?depth=2"
    response = http.request(Net::HTTP::Get.new(coverage_uri))

    # Parse the JSON
    json = JSON.parse(response.body)
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
