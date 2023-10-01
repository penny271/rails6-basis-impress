# ¥ 2.ch.9.3.1 確認画面用プレゼンターの作成
# * FormPresenter のソースコードと比較してください。値を画面上に表示するためのコードが付け加わり、 text_field メソッドや select メソッドが呼ばれていたところが、すべて hidden_field メソッドに置き換わっています。バリデーションが成功した場合しかこのフォームプレゼンターは使われませんので、エラーメッセージを表示する error_messages_for メソッドが存在しません。
# * 必須入力項目を示す赤いアスタリスク（*）をラベルの肩に付ける必要がないため、 notes メソッドは単に空文字を返すだけのものとして、 decorated_label メソッドは単にlabelメソッドを呼ぶだけのものとして定義されています。 続いて、 ConfirmingFormPresenter を継承する ConfirmingUserFormPresenter クラスを定義します。
class ConfirmingFormPresenter
  include HtmlBuilder

  attr_reader :form_builder, :view_context
  delegate :label, :hidden_field, :object, to: :form_builder

  def initialize(form_builder, view_context)
    @form_builder = form_builder
    @view_context = view_context
  end

  def notes
    ""
  end

  def text_field_block(name, label_text, options = {})
    markup(:div) do |m|
      m << decorated_label(name, label_text)
      if options[:disabled]
        m.div(object.send(name), class: "field-value readonly")
      else
        m.div(object.send(name), class: "field-value")
        m << hidden_field(name, options)
      end
    end
  end

  def date_field_block(name, label_text, options = {})
    markup(:div) do |m|
      m << decorated_label(name, label_text)
      m.div(object.send(name), class: "field-value")
      m << hidden_field(name, options)
    end
  end

  def drop_down_list_block(name, label_text, choices, options = {})
    markup(:div) do |m|
      m << decorated_label(name, label_text)
      m.div(object.send(name), class: "field-value")
      m << hidden_field(name, options)
    end
  end

  # ¥ 2.ch.10.1.67 Ajax 顧客向け問い合わせフォーム
  def text_area_block(name, label_text, options = {})
    markup(:div) do |m|
      m << decorated_label(name, label_text)
      value = object.send(name)
      m.div(class: "field-value") do
        # - 顧客が本文に入力した文字列の中に含まれる特殊文字をエスケープした上で、改行文字が含まれていれば、それを <br> タグで置き換えています。
        m << ERB::Util.html_escape(value).gsub(/\n/, "<br>")
      end
      m << hidden_field(name, options)
    end
  end

  def decorated_label(name, label_text)
    label(name, label_text)
  end
end
