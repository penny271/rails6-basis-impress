class UserFormPresenter < FormPresenter
  def password_field_block(name, label_text, options = {})
    # ¥ new_record? メソッド： new_record?メソッドは、オブジェクトがデータベースに保存されていなければtrueを返し、保存されていればfalseを返します。
    #! 新規の場合にのみ、表示させたいため
    if object.new_record?
      # ¥ 20230811 親クラスの同名メソッドを super でオーバーライドしている
      # - 親クラスの同名メソッドの中身をそのまま使用して重複コードを書かないようにしている
      super(name, label_text, options)
    end
  end

  def full_name_block(name1, name2, label_text, options = {})
    # markup(:div) do |m|
    markup(:div, class: "input-block") do |m|
      # m << label(name1, label_text, class: options[:required] ? 'required' : nil)
      m << decorated_label(name1, label_text, options)
      m << text_field(name1, options)
      m << text_field(name2, options)
      m << error_messages_for(name1)
      m << error_messages_for(name2)
    end
  end

end

# <div>
#   <%= f.label :family_name, "氏名", class: "required" %>
#   <%= f.text_field :family_name, required: true %>
#   <%= f.text_field :given_name, required: true %>
# </div>