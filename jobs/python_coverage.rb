require "net/http"
require "json"
require "nokogiri"

host = 'jenkins.edx.org'
port = '8080'
request_uri = '/view/Code/job/edx-deploy-branch-tests/coveragepy/reports/cms/cover/'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new(host, port)
  response = http.request(Net::HTTP::Get.new(request_uri))
  doc = Nokogiri::HTML(response.body)
  pc_cov = doc.at_css("span.pc_cov").text

  send_event('mitx_py_coverage', { title: 'Python Coverage', unordered: true, items: [label: 'CMS', value: pc_cov] })
end
