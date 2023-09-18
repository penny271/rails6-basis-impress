# ¥ 2.ch5.1.2 ipアドレスによるアクセス制限
class AllowedSource < ApplicationRecord
  # ¥ 2.ch5.2.2 許可IPアドレスの管理
  # 4つ目の入力欄は整数の他に * も入力できるので下記を別途用意する ※用意しない場合整数しか入れられない
  #! :last_octet は views/admin/allowed_sources/_new_allowed_source.html.erb で使用している
  #! :_destroy は views/admin/allowed_sources/index.html.erb で使用している
  attr_accessor :last_octet, :_destroy

  before_validation do
    if last_octet
      self.last_octet.strip!
      if last_octet == "*"
        self.octet4 = 0
        self.wildcard = true
      else
        self.octet4 = last_octet
      end
    end
  end

  validates :octet1, :octet2, :octet3, :octet4, presence: true,
    numericality: { only_integer: true, allow_blank: true },
    inclusion: { in: 0..255, allow_blank: true }
  # - :namespace、:octet1、:octet2、:octet3の範囲内で:octet4が一意でなければならない。つまり、2つのレコードが :namespace, :octet1, :octet2, :octet3, :octet4 の同じ組み合わせを持つことはできません。
  validates :octet4,
    uniqueness: {
      scope: [ :namespace, :octet1, :octet2, :octet3 ], allow_blank: true
    }
  # ¥ 2.ch5.2.2 許可IPアドレスの管理
  # - last_octet 属性の値があるリストに含まれているかどうかを確認しています。式 (0..255).to_a.map(&:to_s) は、0から255までの整数を文字列に変換したものの配列を返します。それと配列 [ "*" ] を連結することで、 last_octet 属性に記入可能なすべての値を列挙しています。
  validates :last_octet,
    inclusion: { in: (0..255).to_a.map(&:to_s) + [ "*" ], allow_blank: true }
  # ¥ 2.ch5.2.2 許可IPアドレスの管理
  # - octet4 属性に登録されたエラーメッセージをすべて last_octet 属性のものとして登録し直しています。 presence タイプと uniqueness タイプのバリデーションが octet4 属性に対して行われますが、 octet4 属性に対応する入力欄はフォーム上に存在しないため、フォーム上にエラーの状態を表現できません。しかし、 octet4 属性で生じたエラーを last_octet 属性のエラーとしてしまえば、入力欄の背景色をピンク色に変えることができます。
  after_validation do
    if last_octet
      errors[:octet4].each do |message|
        errors.add(:last_octet, message)
      end
    end
  end


  #- setterを使っている def ip_address=(ip_address)
  def ip_address=(ip_address)
    octets = ip_address.split(".")
    self.octet1 = octets[0]
    self.octet2 = octets[1]
    self.octet3 = octets[2]

    if octets[3] == "*"
      self.octet4 = 0
      self.wildcard = true
    else
      self.octet4 = octets[3]
    end
  end


  # ¥ Rubyでは、class << selfはオブジェクトのシングルトンクラスにメソッドを定義する方法である。クラス定義の文脈では、これによってクラスメソッドを定義することができます。これは、各メソッドに self.method_name を使ってクラスメソッドであることを指定する方法の代わりです。
  class << self
    def include?(namespace, ip_address)
      return true if !Rails.application.config.baukis2[:restrict_ip_addresses]

      octets = ip_address.split(".")

      # - %Q{} in Ruby is a way to define a double-quoted string,
      condition = %Q{
        octet1 = ? AND octet2 = ? AND octet3 = ?
        AND ((octet4 = ? AND wildcard = ?) OR wildcard = ?)
      }.gsub(/\s+/, " ").strip

      # - octets の前に添えられたアスタリスク（*）は、配列をその場に展開します。
      opts = [ condition, *octets, false, true ]
      # [
      #   "octet1 = ? AND octet2 = ? AND octet3 = ? AND ((octet4 = ? AND wildcard = ?) OR wildcard = ?)",
      #   "192", "168", "0", "1", false, true
      # ]
      where(namespace: namespace).where(opts).exists?
    end
  end

end



# ¥ 2.ch5.1.2 ipアドレスによるアクセス制限
# 2-4行では属性 octet1、 octet2、 octet3、 octet4 の値が入力必須であることおよび0から255までの整数値であることを確認しています。
# - inclusion タイプのバリデーションで0から255までの範囲にあることが確認されるので、 numericality タイプのバリデーションは不要のように思えますが、必要です。なぜなら、"XYZ" のような文字列がこれらの属性に代入されると、整数0に変換されてしまい、 inclusion タイプのバリデーションではエラーにならないからです。 numericality タイプのバリデーションは、変換前の値に対して行われるので、正しくエラーと判定されます。
# 5-8行では属性 namespace、 octet1、 octet2、 octet3、 octet4 の値の組み合わせが一意であることを確認しています。バリデーションの対象属性は octet4 ですが、 scope オプションに配列 [ :namespace, :octet1, :octet2, :octet3 ] を指定しているので、5つの属性の組み合わせに関して uniqueness タイプのバリデーションが実施されます。 ip_address=

