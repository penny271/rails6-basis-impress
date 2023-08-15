class FormPresenter
  include HtmlBuilder

  # - 20230811 この宣言は、label、text_field、date_fieldなどのメソッドを定義し、これらのメソッドが呼び出されたら、@form_builderの対応するメソッドにメソッド呼び出しと引数を委譲する（渡す）ことをクラスに指示しています。
  attr_reader :form_builder, :view_context
  delegate :label, :text_field, :date_field, :password_field,
    :check_box, :radio_button, :text_area, :object, to: :form_builder

  def initialize(form_builder, view_context)
    @form_builder = form_builder
    @view_context = view_context
  end

  def notes
    markup(:div, class: "notes") do |m|
      m.span "*", class: "mark"
      m.text "印の付いた項目は入力必須です。"
    end
  end

  def text_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      # m << label(name, label_text, class: options[:required] ? "required" : nil)
      m << decorated_label(name, label_text, options)
      m << text_field(name, options)
      # - 20230811 エラーメッセージの生成
      m << error_messages_for(name)
    end
  end

  def password_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      # m << label(name, label_text, class: options[:required] ? "required" : nil)
      m << decorated_label(name, label_text, options)
      m << password_field(name, options)
      m << error_messages_for(name)
    end
  end

  def date_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      # m << label(name, label_text, class: options[:required] ? "required" : nil)
      m << decorated_label(name, label_text, options)
      m << date_field(name, options)
      m << error_messages_for(name)
    end
  end

  #! 20230813 selectメソッド  引数choices には配列が入る
  def drop_down_list_block(name, label_text, choices, options={})
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      # ¥20230813 フォームビルダーの select メソッドを用いてドロップダウンリスト（セレクトボックス）を生成しています。第2引数には選択項目の配列、第3引数には select メソッドの振る舞いを変更するオプション、第4引数にはHTMLの select 要素に指定する属性を設定するためのオプションを指定します。第3引数で include_blank オプションに true を指定すると、空白の選択肢がリストの先頭に加えられます。
      m << form_builder.select(name, choices, {included_blank: true}, options)
      m << error_messages_for(name)
    end
  end
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # - Railsでは、フォームビルダー（form_withやform_forで作成するようなもの）にはobjectという名前のメソッドがあり、フォームビルダーがフォームを構築している実際のモデルオブジェクト（たとえばStaffMemberやActiveRecordモデルのインスタンス）を返します。このオブジェクトはバリデートされ、潜在的なエラーが添付されます。
  # - ご質問に直接お答えすると、このオブジェクトはフォームビルダーのオブジェクトメソッドから生成され、フォームが構築されるモデルオブジェクトを参照します。
  #¥ 15.4.1　 Errorsオブジェクト モデルオブジェクトの errors メソッドは Errorsオブジェクト を返します。このオブジェクトは、モデルオブジェクトのバリデーションで見つかったエラーに関する情報を保持しています。 Errors オブジェクトの full_messages_for メソッドは、引数に指定された属性に関するエラーメッセージの配列を返します。

  # あなたが提供したコード・スニペットでは、m << error_messages_for(name)行が、指定されたフィールド名に関連するエラーメッセージを、生成されるマークアップに追加する役割を担っています。

  #- しかし、フォームがまだ送信されていない場合、あるいはフォームが送信されたが特定のフィールドのバリデーションエラーがなかった場合、error_messages_for(name)メソッドはエラーメッセージのHTMLを生成しません。

  # 以下はその内訳です：

  #¥ 最初にフォームにアクセスしたとき（データを送信する前）は、まだデータが処理されていないのでバリデーションエラーはありません。したがって、object.errors.full_messages_for(name)は空の配列を返し、error_messages_for内のループは反復処理を行いません。その結果、エラー・メッセージのHTMLは生成されません。

  #¥ フォームを送信し、特定のフィールドにバリデーションエラーがない場合（例えば、パスワードは有効です）、object.errors.full_messages_for(name)は空の配列を返し、エラーメッセージHTMLは生成されません。

  # フォームを送信したときに、特定のフィールドのバリデーション・エラー（パスワードが短すぎる、特定のパターンに一致しないなど）が発生した場合のみ、object.errors.full_messages_for(name)はエラーメッセージの配列を返します。この場合、error_messages_for内のループが実行され、エラーメッセージのHTMLが生成され、m << error_messages_for(name)行によってマークアップに追加されます。

  # 要約すると、m << error_messages_for(name)行は常にerror_messages_for(name)の出力をマークアップに追加していますが、その出力は特定のフィールドで実際にバリデーションエラーが発生するまでは空（エラーメッセージなし）です。
  def error_messages_for(name)
    markup do |m|
      # ¥ form_builder.object を delegate で objectで呼び出せるようにしている 20230813
      object.errors.full_messages_for(name).each do |message|
        m.div(class: "error-message") do |m|
          m.text message
        end
      end
    end
  end

  # # ¥ 条件により入力必須マークがついたラベルタグを作成する
  # private def decorated_label(name, label_text, options = {})
  #   label(name, label_text, class: options[:required] ? "required" : nil)
  # end

  # ¥ 条件により入力必須マークがついたラベルタグを作成する
  def decorated_label(name, label_text, options = {})
    label(name, label_text, class: options[:required] ? "required" : nil)
  end

end

