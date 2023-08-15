class AddressPresenter < ModelPresenter
  # - model_presenterより下記を継承しているため getterの仕様を利用してobjectメソッドを使うことができる 20230813
  # attr_reader :object, :view_context
  # def initialize(object, view_context)
  #   @object = object
  #   @view_context = view_context
  # end
  delegate :prefecture, :city, :address1, :address2,
    :company_name, :division_name, to: :object

  # ¥ このメソッドは、連続する7桁の数字として格納されている郵便番号が、より人間が読みやすい形式（"XXX-XXXX"）で表示されるようにします。郵便番号がこの正確な形式で保存されていない場合、このメソッドは再フォーマットを試みず、そのまま返します。 md は medaDataの省略名
  def postal_code
    if md = object.postal_code.match(/\A(\d{3})(\d{4})\z/)
      md[1] + "-" + md[2]
    else
      object.postal_code
    end
  end

  def phones
    object.phones.map(&:number)
  end
end