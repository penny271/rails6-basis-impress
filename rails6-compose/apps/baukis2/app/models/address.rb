class Address < ApplicationRecord
  include StringNormalizer

  belongs_to :customer
  # ¥ 5行目でクラスメソッド has_many を用いて、 Address モデルと Phone モデルとの間に1対多の関連付けを行っています。第2引数にはスコープを表す Proc オブジェクトを指定しました。ここでは関連付けの範囲を絞り込むためではなく、ソート順を一定にする目的でスコープを用いています
  has_many :phones, -> { order(:id) }, dependent: :destroy, autosave: true

  #  - 値の正規化 バリデーションの前に行う 20230813
  before_validation do
    self.postal_code = normalize_as_postal_code(postal_code)
    self.city = normalize_as_name(city)
    self.address1 = normalize_as_name(address1)
    self.address2 = normalize_as_name(address2)
  end

  # PREFECTURE_NAMES = %w(
  #   北海道
  #   青森県 岩手県 宮城県 秋田県 山形県 福島県
  #   茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
  #   新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県
  #   三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県
  #   鳥取県 島根県 岡山県 広島県 山口県
  #   徳島県 香川県 愛媛県 高知県
  #   福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県
  #   沖縄県
  #   日本国外
  # )

  # - 2.ch3 20230819 このようにすることで フィルタリングで '' を選択可能になり、すべての件を検索対象にできる
  # ¥ Rubyでは、.freezeメソッドはオブジェクトをイミュータブル(要素の追加及び変更不可)にするために使われる。
  PREFECTURE_NAMES = [
    "",
    "北海道",
    "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
    "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
    "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県",
    "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
    "鳥取県", "島根県", "岡山県", "広島県", "山口県",
    "徳島県", "香川県", "愛媛県", "高知県",
    "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県",
    "沖縄県",
    "日本国外"
  ].freeze

  validates :postal_code, format: { with: /\A\d{7}\z/, allow_blank: true }
  validates :prefecture, inclusion: { in: PREFECTURE_NAMES, allow_blank: true }
end

# - Addressモデル、HomeAddressモデル、WorkAddressモデル、 HomeAddress モデルと WorkAddress モデルは、値の正規化やバリデーションに関して共通する部分もあれば、異なっている部分もあります。たとえば、郵便番号の正規化や形式チェックは同じやり方で行うことになりますが、 presence タイプのバリデーションは HomeAddress モデルでしか行いません（勤務先の郵便番号は任意項目）。

#¥ 両モデルで共通する部分は両モデルの親である Address モデルで記述し、異なっている部分はそれぞれのモデルで記述します。