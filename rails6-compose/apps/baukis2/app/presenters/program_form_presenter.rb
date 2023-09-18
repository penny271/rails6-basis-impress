# ¥ 2.ch7.1.6
class ProgramFormPresenter < FormPresenter
  def description
    markup(:div, class: "input-block") do |m|
      m << decorated_label(:description, "詳細", required: true)
      m << text_area(:description, rows: 6, style: "width: 454px")
      m.span "（800⽂字以内）", class: "instruction", style: "float: right"
      m << error_messages_for(:description)
    end
  end

  def datetime_field_block(name, label_text, options = {})
    # * ハッシュoptionsから :instructionキーを削除して、その値をローカル変数
    # * instructionsにセットしている
    instruction = options.delete(:instruction)
    if object.errors.include?("#{name}_time".to_sym)
        html_class = "input-block with-errors"
      else
        html_class = "input-block"
    end

    # markup(:div, class: 'input-block') do |m|
    markup(:div, class: html_class) do |m|
      puts("----name: #{name}")  # ----name: application_start
      #! 上記からも分かる通り、symbolを単体で呼び出すと、.to_sで自動的に文字列に変換される
      m << decorated_label("#{name}_date", label_text, options)
      m << date_field("#{name}_date", options)
      m << form_builder.select("#{name}_hour", hour_options)
      m << ":"
      m << form_builder.select("#{name}_minute", minute_options)
      m.span "（#{instruction}）", class: "instruction" if instruction
      m << error_messages_for("#{name}_time".to_sym)
      m << error_messages_for("#{name}_date".to_sym)
    end
  end

  # * 式 "%02d" % h は、整数 h を2桁の文字列に変換します。 h が10未満の場合は、先頭に "0" を付け加えます。 　このプライベートメソッド hour_options は、15行目においてフォームビルダーの select メソッドへの第2引数を作るために使われています。 select メソッドは第2引数に指定された配列の各要素を用いてドロップボックスの選択肢を作りますが、上記のような入れ子の配列を第2引数として受け取った場合は、各要素、すなわち内側の配列の第1要素を選択肢のラベル文字列、第2要素を選択肢の値として使用します
  private def hour_options # [0,1,...,22,23]に相当するRangeオブジェクト
    (0..23).map { |h| [ "%02d" % h, h ] }
  end

  # * 5ずつ離れた0から55までの整数を選ぶドロップボックスを生成するために使用
  private def minute_options
    (0..11)
      .map { |n| n * 5}
      .map { |m| [ "%02d" % m, m ] }
  end
end