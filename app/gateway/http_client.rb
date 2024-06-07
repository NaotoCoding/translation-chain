require "net/http"
require "uri"

class HttpClient
  def post(end_point, headers, body, use_ssl: true)
    uri = URI(end_point)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = use_ssl
    request = Net::HTTP::Post.new(uri)
    headers.each { |key, value| request[key] = value }
    request.body = body.to_json
    https.request(request)
  end
end
