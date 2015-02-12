require 'nokogiri'
#require 'open-uri'
require 'openssl'
require 'json'

analytics_repos_on_coveralls = Hash[
    "edx-analytics-dashboard" => "dashboard_unit",
    "edx-analytics-data-api"=> "data_api_unit",
    "edx-analytics-data-api-client" => "data_api_client_unit"
]


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    analytics_repos_on_coveralls.each do | repo, metric |

        # Retrieve the coverage info as HTML
        coverage_url = COVERALLS_URL + "#{repo}?branch-master"
        coverage_data = open(coverage_url, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

        # Parse the HTML
        doc = Nokogiri::HTML(coverage_data)

        line_coverage = doc.at_css("#repoShowPercentage").text.gsub(/[%\n]/,'')

        send_event("#{metric}",   { value: line_coverage })
    end
end
