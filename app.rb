require "aws-sdk-ssm"
require_relative "app/gateway/deepl_client"
require_relative "app/translation_chain"

def check_arguments(initial_text:, initial_source_lang:, target_langs:)
  raise ArguemntError if initial_text.empty?
  raise ArgumentError unless DeeplClient::DEEPL_TRANSLATABLE_SOURCE_LANGS.keys.include?(initial_source_lang)
  # TODO: 翻訳を連鎖した時、翻訳後の言語が再度翻訳のsourceとなり得ないパターンに対応する必要あり
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
  result = TranslationChain.new(translation_client: DeeplClient.new(deepl_auth_key:)).call(initial_text:, initial_source_lang:, target_langs:)
  { statusCode: 200, body: result.to_json }
end
