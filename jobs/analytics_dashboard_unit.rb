require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'json'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the coverage info as HTML
    coverage_url = COVERALLS_URL + "edx-analytics-dashboard?branch-master"
    coverage_data = open(coverage_url, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    # Parse the HTML
    doc = Nokogiri::HTML(coverage_data)

    line_coverage = doc.at_css("#repoShowPercentage").text.gsub(/[%\n]/,'')

    send_event('analtyics_dashboard_unit',   { value: line_coverage })
end
