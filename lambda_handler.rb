require "net/http"
require "uri"
require "json"
require "aws-sdk-ssm"

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

class DeeplClient
  DEEPL_API_FREE_URI = "https://api-free.deepl.com/v2/translate".freeze
  DEEPL_TRANSLATABLE_SOURCE_LANGS = {
    "BG" => "ブルガリア語",
    "CS" => "チェコ語",
    "DA" => "デンマーク語",
    "DE" => "ドイツ語",
    "EL" => "ギリシャ語",
    "EN" => "英語",
    "ES" => "スペイン語",
    "ET" => "エストニア語",
    "FI" => "フィンランド語",
    "FR" => "フランス語",
    "HU" => "ハンガリー語",
    "ID" => "インドネシア語",
    "IT" => "イタリア語",
    "JA" => "日本語",
    "KO" => "韓国語",
    "LT" => "リトアニア語",
    "LV" => "ラトビア語",
    "NB" => "ノルウェー語",
    "NL" => "オランダ語",
    "PL" => "ポーランド語",
    "PT" => "ポルトガル語",
    "RO" => "ルーマニア語",
    "RU" => "ロシア語",
    "SK" => "スロバキア語",
    "SL" => "スロベニア語",
    "SV" => "スウェーデン語",
    "TR" => "トルコ語",
    "UK" => "ウクライナ語",
    "ZH" => "中国語"
  }.freeze
  DEEPL_TRANSLATABLE_TARGET_LANGS = {
    "BG" => "ブルガリア語",
    "CS" => "チェコ語",
    "DA" => "デンマーク語",
    "DE" => "ドイツ語",
    "EL" => "ギリシャ語",
    "EN-GB" => "英語（イギリス）",
    "EN-US" => "英語（アメリカ）",
    "ES" => "スペイン語",
    "ET" => "エストニア語",
    "FI" => "フィンランド語",
    "FR" => "フランス語",
    "HU" => "ハンガリー語",
    "ID" => "インドネシア語",
    "IT" => "イタリア語",
    "JA" => "日本語",
    "KO" => "韓国語",
    "LT" => "リトアニア語",
    "LV" => "ラトビア語",
    "NB" => "ノルウェー語（ブークモール）",
    "NL" => "オランダ語",
    "PL" => "ポーランド語",
    "PT-BR" => "ポルトガル語（ブラジル）",
    "PT-PT" => "ポルトガル語（ポルトガル）",
    "RO" => "ルーマニア語",
    "RU" => "ロシア語",
    "SK" => "スロバキア語",
    "SL" => "スロベニア語",
    "SV" => "スウェーデン語",
    "TR" => "トルコ語",
    "UK" => "ウクライナ語",
    "ZH" => "中国語（簡体字・繁体字）"
  }.freeze

  def initialize(deepl_auth_key:, http_client: HttpClient.new)
    @deepl_auth_key = deepl_auth_key
    @http_client = http_client
  end

  def call(text:, source_lang:, target_lang:)
    response = @http_client.post(
      DEEPL_API_FREE_URI,
      {
        "Authorization" => "DeepL-Auth-Key #{@deepl_auth_key}",
        "Content-Type" => "application/json"
      },
      { text: [text], source_lang:, target_lang: }
    )
    JSON.parse(response.body)["translations"].first["text"]
  end
end

class TranslationChain
  def initialize(translation_client:)
    @translation_client = translation_client
  end

  def call(initial_text:, initial_source_lang:, target_langs:)
    initial_result = [lang: initial_source_lang, text: initial_text]
    target_langs.each_with_object(initial_result).with_index do |(target_lang, result), index|
      source_lang = index.zero? ? initial_source_lang : target_langs[index - 1]
      text = index.zero? ? initial_text : result.last["text"]
      result << { "lang" => target_lang, "text" => @translation_client.call(text:, source_lang:, target_lang:) }
    end
  end
end

#--------------------------------------------------------------------------
def check_arguments(initial_text:, initial_source_lang:, target_langs:)
  raise ArguemntError if initial_text.empty?
  raise ArgumentError unless DeeplClient::DEEPL_TRANSLATABLE_SOURCE_LANGS.keys.include?(initial_source_lang)
  raise ArgumentError unless (target_langs - DeeplClient::DEEPL_TRANSLATABLE_TARGET_LANGS.keys).empty?
end

def ssm_parameter(parameter_key)
  Aws::SSM::Client.new
                  .get_parameter({ name: parameter_key, with_decryption: true })
                  .parameter
                  .value
end

def lambda_handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  body = JSON.parse(event["body"])
  initial_text = body["initial_text"]
  initial_source_lang = body["initial_source_lang"]
  target_langs = body["target_langs"]
  check_arguments(initial_text:, initial_source_lang:, target_langs:)

  deepl_auth_key = ssm_parameter("/translation-chain/deepl-auth-key")
  result = TranslationChain.new(deepl_auth_key).call(initial_text:, initial_source_lang:, target_langs:)
  { statusCode: 200, body: result.to_json }
end

