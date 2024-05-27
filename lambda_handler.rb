require "net/http"
require "uri"
require "json"

class TranslationChain
  DEEPL_API_FREE_URI = "https://api-free.deepl.com/v2/translate".freeze

  def initialize(translation_client_auth_key)
    @translation_client_auth_key = translation_client_auth_key
  end

  def call
    puts translate("JA", "DE", "こんにちは")
  end

  private

    def translate(source_lang, target_lang, text)
      response = request_post(
        DEEPL_API_FREE_URI,
        {
          "Authorization" => "DeepL-Auth-Key #{@translation_client_auth_key}",
          "Content-Type" => "application/json"
        },
        { source_lang:, target_lang:, text: [text] }
      )
      response.body
    end

    def request_post(end_point, headers, body, use_ssl: true)
      uri = URI(end_point)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = use_ssl
      request = Net::HTTP::Post.new(uri)
      headers.each do |key, value|
        request[key] = value
      end
      request.body = body.to_json
      https.request(request)
    end
end

#--------------------------------------------------------------------------

def lambda_handler; end
