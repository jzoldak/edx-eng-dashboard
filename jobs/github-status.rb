require "net/https"
require "json"
require "uri"

uri = URI.parse("https://status.github.com/api/status.json")
widget = 'github_status'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
# TODO: rescue Timeout::Error if the back end does not respond
SCHEDULER.every '1m', :first_in => 0 do |job|

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    response = http.request(request)
    b = response.body
    status = JSON.parse(b)['status']

    # note: status warning=red and danger=orange
    if response.code != '200'
        send_event(widget, { title: 'GitHub', text: response.code, status: 'danger' })
    else
        if status.nil?
            code = 'danger'
        elsif status == 'good'
            code = 'ok'
        elsif status == 'minor'
            code == 'danger'
        elsif status == 'major'
            code == 'warning'
        else
            code == 'danger'
        end
        send_event(widget, { text: status, status: code })
    end
end
