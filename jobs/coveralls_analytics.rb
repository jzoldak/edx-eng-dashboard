require 'nokogiri'
require 'openssl'
require 'json'
require 'open-uri'

analytics_repos_on_coveralls = Hash[
    "edx-analytics-dashboard" => "dashboard_unit",
    "edx-analytics-data-api"=> "data_api_unit",
    "edx-analytics-data-api-client" => "data_api_client_unit",
    "edx-analytics-pipeline" => "pipeline_unit"
]


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    analytics_repos_on_coveralls.each do | repo, metric |
        # Cycle through repos, get coverage data, and send to browser
        line_coverage = get_coverage_from_coveralls(repo)
        send_event("#{metric}",   { value: line_coverage })
    end
end

def get_coverage_from_coveralls(repo)
# Coveralls has no retrieval API (at this time). To get coverage, scrape the page
# for latest unit test coverage data.

        # Retrieve the coverage info as HTML
        coverage_url = COVERALLS_URL + "#{repo}?branch-master"
        coverage_data = open(coverage_url, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

        # Get coverage % as presented on page
        doc = Nokogiri::HTML(coverage_data)
        line_coverage = doc.at_css("#repoShowPercentage").text.gsub(/[%\n]/,'')

end
