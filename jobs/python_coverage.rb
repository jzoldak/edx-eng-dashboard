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
SCHEDULER.every '1m', :first_in => 0 do |job|
    systems.each do |system|
        request_uri = uri_base + system + '/cover/'
        response = http.request(Net::HTTP::Get.new(request_uri))
        doc = Nokogiri::HTML(response.body)
        pc_cov[system] = doc.at_css("span.pc_cov").text
    end

    send_event('mitx_py_coverage', { title: 'Python Coverage', unordered: true, 
        items: [{label: 'CMS', value: pc_cov['cms']}, 
                {label: 'LMS', value: pc_cov['lms']},
                {label: 'capa', value: pc_cov['common/lib/capa']},
                {label: 'xmodule', value: pc_cov['common/lib/xmodule']}] })
end
