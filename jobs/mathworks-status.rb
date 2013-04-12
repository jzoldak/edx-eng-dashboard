require "net/https"
require "json"
require "uri"

uri = URI.parse("https://prod.mss-mathworks.com/stateless/mooc/edX")
data = {"xqueue_body" => "{\"student_response\": \"x=1\\n\", \"grader_payload\": \"%api_key=API_KEY_HERE\\n%%\\nassert(isequal(x,1))\\n\"}"}.to_json

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
# TODO: rescue Timeout::Error if the back end does not respond
SCHEDULER.every '1m', :first_in => 0 do |job|

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = data
    request["Content-Type"] = "application/json"
    response = http.request(request)
    b = response.body
    fault = JSON.parse(b)['fault']
    correct = JSON.parse(b)['correct']

    # note: status warning=red and danger=orange
    if response.code == '200'
        if fault.nil?
            if correct == true
                send_event('mathworks_status', { title: 'Mathworks API', text: "Up", status: 'ok' })
            else # responsed but with the wrong value for "correct"
                send_event('mathworks_status', { title: 'Mathworks API: Error', text: b, status: 'danger' })
            end
        else
            send_event('mathworks_status', { title: 'Mathworks API', text: fault, status: 'warning' })
        end
    else
        send_event('mathworks_status', { title: 'Mathworks API', text: response.code, status: 'danger' })
    end
end
