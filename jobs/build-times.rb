require 'open-uri'
require 'openssl'
require 'json'

BUILD_SAMPLE_SIZE = 15

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve job data
    build_info_uri = JENKINS_JOB_URL + '/api/json?tree=builds[number,status,timestamp,id,result,duration]'

    # Once SSL certificates are set up correctly, we can remove the :ssl_verify_mode option
    response = open(build_info_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    json = JSON.parse(response)

    build_time_average = get_average_build_time(json)
    send_event('build_time_average',   { value: build_time_average })
end

def get_average_build_time(json)
# Given a JSON tree of build info, it will calculate the average build time in
# minutes over the last 16 builds.

    build_info = json.fetch("builds")
    total_build_time = 0
    total_builds_counted = 0
    build_info.map.each do | k, v |
        if ( k["result"] == "SUCCESS" && k["duration"] > 0 )
            total_build_time += k["duration"]
            total_builds_counted += 1
            break if total_builds_counted > BUILD_SAMPLE_SIZE
        end
    end

    build_time_average = (total_build_time / total_builds_counted) / 60000
    build_time_average = build_time_average.round(0).to_i
    return build_time_average


end
