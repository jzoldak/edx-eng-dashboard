require "net/http"
require "json"
require "nokogiri"

host = 'jenkins.edx.org'
port = '8080'
http = Net::HTTP.new(host, port)

uri_base = '/view/Code/job/edx-deploy-branch-tests/coveragepy/reports/'
systems = ['cms', 'lms', 'common/lib/capa', 'common/lib/xmodule']
pc_cov = {}

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|
    systems.each do |system|
        request_uri = uri_base + system + '/cover/'
        response = http.request(Net::HTTP::Get.new(request_uri))
        doc = Nokogiri::HTML(response.body)
        pc_cov[system] = doc.at_css("span.pc_cov").text
    end

    send_event('py_cms',   { value: pc_cov['cms'].delete('%').to_i })
    send_event('py_lms',   { value: pc_cov['lms'].delete('%').to_i })
    send_event('py_capa',   { value: pc_cov['common/lib/capa'].delete('%').to_i })
    send_event('py_xmodule',   { value: pc_cov['common/lib/xmodule'].delete('%').to_i })

end
