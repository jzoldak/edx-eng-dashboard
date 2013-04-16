require "net/https"
require "json"
require "uri"

uri = URI.parse("https://status.github.com/api/status.json")
widget = 'github_status'

# :first_in sets how long it takes before the job is first run.
# In this case, it is run immediately.
# TODO: rescue Timeout::Error if the back end does not respond
SCHEDULER.every '10s', :first_in => 0 do |job|

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    begin
        response = http.request(request)
        b = response.body
        status = JSON.parse(b)['status']
        updated = JSON.parse(b)['last_updated']

        # note: status warning=red and danger=orange
        if response.code != '200'
            send_event(widget, { title: 'GitHub', text: response.code,
                status: 'danger', moreinfo: 'response code is not 200' })
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
            send_event(widget, { text: status, status: code, moreinfo: updated })
        end
    rescue Timeout::Error
        send_event(widget, { title: 'GitHub', text: 'Timeout',
            status: 'danger', moreinfo: 'timeout exception caught' })
    end
end
