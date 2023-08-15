class HomeAddress < Address
  validates :postal_code, :prefecture, :city, :address1, presence: true
  # - absenseタイプのバリデーションは指定された属性が空であることを確認する
  validates :company_name, :division_name, absence: true
end