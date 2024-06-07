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
