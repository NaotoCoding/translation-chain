require "json"
require_relative "http_client"

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
