require "net/http"
require "json"
require "nokogiri"

host = 'jenkins.edx.org'
port = '8080'
http = Net::HTTP.new(host, port)
request_uri = '/view/Code/job/edx-deploy-branch-tests/violations/?'

SCHEDULER.every '1m', :first_in => 0 do |job|
    response = http.request(Net::HTTP::Get.new(request_uri))
    doc = Nokogiri::HTML(response.body)
    current_pep8 = doc.at_css("table.pane > tbody > tr:nth-of-type(2) > td:nth-of-type(2)").text
    current_pylint = doc.at_css("table.pane > tbody > tr:nth-of-type(3) > td:nth-of-type(2)").text

    send_event('pep8', { current: current_pep8 })
    send_event('pylint', { current: current_pylint })
end
