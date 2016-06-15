require 'cog/command'
require 'net/http'
require 'json'
class CogCmd::Pingdom::Check < Cog::Command

  def run_command
    args = request.args
    subcommand = args[0]

    case subcommand
    when "list"
      api_response = make_api_request("/checks")
      response.template = "check"
      response.content = JSON.parse(api_response.body)["checks"]
    when "show"
      args.shift
      if id = args[0]
        api_response = make_api_request("/checks/#{id}")
        response.content = JSON.parse(api_response.body)["check"]
      else
        fail("Must supply a check ID")
      end
    when "results"
      args.shift
      if id = args[0]
        limit = if count = request.options["count"]
                  Integer(count)
                 else
                   1
                 end

        api_response = make_api_request("/results/#{id}",
                                        params: {"limit" => limit})
        response.content = JSON.parse(api_response.body)["results"]
      else
        fail("Must supply a check ID")
      end
    else
      fail("Must specify 'list', 'show', or 'results' subcommand")
    end
  end

  ##################

  # There isn't an up-to-date Ruby library for Pingdom, but we only
  # need to make a handful of API calls, so we'll roll our own for
  # now. As more commands are added to the bundle, we can extract this
  # as appropriate.

  API_BASE = "https://api.pingdom.com/api/2.0"

  # Makes a HTTPS, Basic Authentication Pingdom API request. Pulls
  # authentication information from the environment as appropriate.
  #
  # @param path [String] The portion of the REST API URL after the
  #        base. Should include a leading slash.
  # @option opts [Hash] :params (nil) Key-value pairs for query string
  #         parameters
  #
  # @return [Net::HTTPResponse] the successful HTTP response; will
  #         exit the process otherwise
  def make_api_request(path, params: nil)
    user_email      = env_var("PINGDOM_USER_EMAIL", required: true)
    user_password   = env_var("PINGDOM_USER_PASSWORD", required: true)
    application_key = env_var("PINGDOM_APPLICATION_KEY", required: true)

    query_string = params ? "?#{URI.encode_www_form(params)}" : ""

    uri = URI("#{API_BASE}#{path}#{query_string}")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth(user_email, user_password)
    req["App-Key"] = application_key
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      resp = http.request(req)
      case resp
      when Net::HTTPSuccess
        resp
      else
        error = JSON.parse(resp.body)["error"]
        fail("Pingdom API Request Failure: #{error["statuscode"]} (#{error["statusdesc"]}) -  #{error["errormessage"]}")
      end
    end
  end

end
