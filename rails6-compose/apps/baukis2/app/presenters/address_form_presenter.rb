class AddressFormPresenter < FormPresenter
  # - FormPresenterより下記を継承しているため getterの仕様を利用して下記のメソッドを使うことができる 20230813
  # attr_reader :form_builder, :view_context
  # delegate :label, :text_field, :date_field, :password_field,
  #   :check_box, :radio_button, :text_area, :object, to: :form_builder
  def postal_code_block(name, label_text, options)
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      m << text_field(name, options)
      m.span " (7桁の半角数字で入力してください。)", class: "notes"
      m << error_messages_for(name)
    end
  end
end