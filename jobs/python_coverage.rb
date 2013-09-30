require "net/http"
require "json"
require "nokogiri"


JENKINS_BASE_URL = 'https://jenkins.testeng.edx.org'

uri_base = '/view/Code/job/edx-deploy-branch-tests/coveragepy/reports/'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the number of the last stable build
    last_build_uri = JENKINS_BASE_URL + '/job/edx-platform-master/lastStableBuild/buildNumber'

    # Once SSL certificates are set up correctly, we can remove the :ssl_verify_mode option
    response = open(last_build_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read
    last_build_num = response.to_i

    # Retrieve all Python coverage info for the last successful job
    coverage_uri = JENKINS_BASE_URL + "/job/edx-platform-master/SHARD=1,TEST_SUITE=unit/#{last_build_num}/cobertura/_default_/api/json?depth=3"
    coverage_data = open(coverage_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    # Parse the JSON
    json = JSON.parse(coverage_data)

    # Collect coverage by filename and keep track of totals
    total_lines = { "lms" => 0, "cms" => 0, "common" => 0 }
    covered_lines = { "lms" => 0, "cms" => 0, "common" => 0 }

    file_results = json['results']['children']
    file_results.each do |result|

        # Name is the path to the source file
        src_path = result['name']

        # The first "element" is line coverage
        # (indices 0 and 2 are class and branch coverage respectively)
        line_coverage = result['elements'][1]

        if src_path.start_with?('lms/') or src_path.start_with?('common/djangoapps')
            covered_lines['lms'] += line_coverage['numerator']
            total_lines['lms'] += line_coverage['denominator']
        end

        if src_path.start_with?('cms/') or src_path.start_with?('common/djangoapps')
            covered_lines['cms'] += line_coverage['numerator']
            total_lines['cms'] += line_coverage['denominator']
        end

        if src_path.start_with?('common/lib')
            covered_lines['common'] += line_coverage['numerator']
            total_lines['common'] += line_coverage['denominator']
        end
    end

    # Calculate coverage percentages
    lms_cov = covered_lines['lms'] / total_lines['lms'] * 100
    cms_cov = covered_lines['cms'] / total_lines['cms'] * 100
    common_cov = covered_lines['common'] / total_lines['common'] * 100

    send_event('py_lms', { value: lms_cov.to_i })
    send_event('py_cms', { value: cms_cov.to_i })
    send_event('py_common', { value: common_cov.to_i })

end
