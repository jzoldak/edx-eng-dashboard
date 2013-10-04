require "net/http"
require "json"
require "nokogiri"


JENKINS_BASE_URL = 'https://jenkins.testeng.edx.org'
JENKINS_JOB_NAME = 'edx-all-tests-auto-master'
JENKINS_JOB_URL = JENKINS_BASE_URL + '/job/' + JENKINS_JOB_NAME

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|

    # Retrieve the number of the last stable build
    last_build_uri = JENKINS_JOB_URL + '/lastStableBuild/buildNumber'

    # Once SSL certificates are set up correctly, we can remove the :ssl_verify_mode option
    response = open(last_build_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read
    last_build_num = response.to_i

    # Retrieve all Python coverage info for the last successful job
    coverage_uri = JENKINS_JOB_URL + "/SHARD=1,TEST_SUITE=unit/#{last_build_num}/cobertura/_default_/api/json?depth=3"
    coverage_data = open(coverage_uri, :ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE).read

    # Parse the JSON
    json = JSON.parse(coverage_data)

    # Collect coverage by filename and keep track of totals
    suites = ['lms', 'cms', 'common/djangoapps', 'common/lib']
    total_lines = {}
    covered_lines = {}

    # Start with 0 total and covered lines for each suite
    suites.each do |suite|
        total_lines[suite] = 0
        covered_lines[suite] = 0
    end

    file_results = json['results']['children']
    file_results.each do |result|

        # Name is the path to the source file
        src_path = result['name']

        # The first "element" is line coverage
        # (indices 0 and 2 are class and branch coverage respectively)
        line_coverage = result['elements'][1]

        # Increment the covered and total numbers of lines
        # for each of the suites
        suites.each do |suite|
            if src_path.start_with?(suite)
                covered_lines[suite] += line_coverage['numerator']
                total_lines[suite] += line_coverage['denominator']
            end
        end
    end

    # Calculate coverage percentages
    lms_cov = covered_lines['lms'] / total_lines['lms'] * 100
    cms_cov = covered_lines['cms'] / total_lines['cms'] * 100
    common_lib_cov = covered_lines['common/lib'] / total_lines['common/lib'] * 100
    common_apps_cov = covered_lines['common/djangoapps'] / total_lines['common/djangoapps'] * 100

    send_event('py_lms', { value: lms_cov.to_i })
    send_event('py_cms', { value: cms_cov.to_i })
    send_event('py_common_lib', { value: common_lib_cov.to_i })
    send_event('py_common_apps', { value: common_apps_cov.to_i })

end
