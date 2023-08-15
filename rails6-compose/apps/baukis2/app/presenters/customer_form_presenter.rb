class CustomerFormPresenter < UserFormPresenter
  # - FormPresenterより下記を継承しているため getterの仕様を利用して下記のメソッドを使うことができる 20230813
  # attr_reader :form_builder, :view_context
  # delegate :label, :text_field, :date_field, :password_field,
  #   :check_box, :radio_button, :text_area, :object, to: :form_builder
  def gender_field_block
    markup(:div, class: "radio-buttons") do |m|
      m << decorated_label(:gender, "性別")
      m << radio_button(:gender, "male")
      m << label(:gender_male, "男性")
      m << radio_button(:gender, "female")
      m << label(:gender_female, "女性")
    end
  end
end