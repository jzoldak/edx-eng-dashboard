require "net/http"
require "json"

port = '8099'
request_uri = '/versions.json'

p_hosts = ["prod-edge-edxapp-001",
           "prod-edge-edxapp-002",
           "prod-edxapp-004",
           "prod-edxapp-005",
           "prod-edxapp-006",
           "prod-edxapp-007",
           "prod-edxapp-008",
           "prod-edxapp-009"
           ]
s_hosts = ["stage-edge-edxapp-001",
           "stage-edge-edxapp-002",
           "stage-edxapp-001",
           "stage-edxapp-002"
           ]

suffix = '.m.edx.org'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
    prod_hash = Hash.new({ value: "N/A" })
    p_hosts.each do |host|
        http = Net::HTTP.new(host + suffix, port)
        response = http.request(Net::HTTP::Get.new(request_uri))
        mitx_hash = JSON.parse(response.body)['edx-platform']
        prod_hash[host] =  { label: host, value: mitx_hash }
    end
    stage_hash = Hash.new({ value: "N/A" })
    s_hosts.each do |host|
        http = Net::HTTP.new(host + suffix, port)
        response = http.request(Net::HTTP::Get.new(request_uri))
        mitx_hash = JSON.parse(response.body)['edx-platform']
        stage_hash[host] = { label: host, value: mitx_hash }
    end

    send_event('mitx_hash_prod', { title: 'Production Version', unordered: true, items: prod_hash.values })
    send_event('mitx_hash_stage', { title: 'Staging Version', unordered: true, items: stage_hash.values })
end
