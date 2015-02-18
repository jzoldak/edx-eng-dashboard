require 'open-uri'
require 'openssl'
require 'json'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the number of the last stable build

    dashboard_js = 70

    send_event('dashboard_js',   { value: dashboard_js })
end
