require "open-uri"
require "openssl"
require "nokogiri"

SCHEDULER.every '1m', :first_in => 0 do |job|

    violations_uri = JENKINS_JOB_URL + '/SHARD=1,TEST_SUITE=quality/violations/?'

    violations_data = open(violations_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    doc = Nokogiri::HTML(violations_data)
    current_pep8 = doc.at_css("table.pane > tbody > tr:nth-of-type(2) > td:nth-of-type(2)").text
    current_pylint = doc.at_css("table.pane > tbody > tr:nth-of-type(3) > td:nth-of-type(2)").text

    send_event('pep8', { value: current_pep8.split(" ")[0].to_i })
    send_event('pylint', { value: current_pylint.split(" ")[0].to_i })
end
