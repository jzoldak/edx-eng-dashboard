require "net/http"
require "json"

host = 'prod-edx-001.m.edx.org'
port = '8099'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new(host, port)
  response = http.request(Net::HTTP::Get.new('/versions.json'))
  mitx_hash = JSON.parse(response.body)['mitx']
  send_event('mitx_hash', { mitx: mitx_hash })
end
