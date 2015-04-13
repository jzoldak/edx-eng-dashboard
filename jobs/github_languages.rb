require 'open-uri'
require 'openssl'
require 'json'

analytics_repos_on_github = Hash[
    "edx-analytics-dashboard" => "langs_dashboard",
    "edx-analytics-data-api"=> "langs_data_api",
    "edx-analytics-data-api-client" => "langs_data_api_client",
    "edx-analytics-pipeline" => "langs_pipeline",
    "ecommerce" => "langs_ecommerce",
    "auth-backends" => "langs_auth_backends"
]


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|



    analytics_repos_on_github.each do | repo, metric |
        progress_array = calculate_lang_percentages(repo)
        send_event(metric, { title: "", progress_items: progress_array })
    end
end

def calculate_lang_percentages(repo)
    lang_url = "https://api.github.com/repos/edx/#{repo}/languages"
    lang_vals = open(lang_url, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read
    lang_json = JSON.parse(lang_vals)
    total_lines = lang_json.values.inject(:+).to_f
    lang_percentages = get_lang_percentages(lang_json, total_lines)

    progress_array = []
    lang_percentages.each do | lang, perc |
        lang_hash = Hash[name: lang, progress: perc]
        progress_array.push(lang_hash)
    end
    return progress_array

end


def get_lang_percentages(lang_json, total_lines)

    return lang_json.inject({}) { | h, (k, v)| h[k] = ((v.to_f/total_lines.to_f) * 100); h}


end
