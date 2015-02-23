require "open-uri"
require "openssl"
require "nokogiri"

SCHEDULER.every '1m', :first_in => 0 do |job|

    s3_key = 'edx-analytics-dashboard/master/test_eng.coverage.javascript.analytics_dashboard'
    s3_uri = S3_URL + S3_BUCKET + "/" + s3_key

    dashboard_js = get_data_from_s3(s3_uri)
    send_event('dashboard_js',   { value: dashboard_js })

end

def get_data_from_s3(s3_uri)
# Assumption is that the data is contained in an S3 text file. One value, one line.
# File must have public_url ACL permissions.

    s3_data = open(s3_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read
    doc = Nokogiri::HTML(s3_data)
    stat = doc.at_css("p").text.to_i

    return stat

end
