class Customer < ApplicationRecord
  include EmailHolder # ^ emailのバリデーション
  include PersonalNameHolder

  #  - 1対1の関連付け
  # has_one :home_address, dependent: :destroy
  # has_one :work_address, dependent: :destroy
  # - 20230814 autosave オプションに true を指定すると、常に Customer オブジェクトがデータベースに保存される際に、関連付けられたオブジェクトも自動的にデータベースに保存されるようになります。 autosaveオプションにfalseを指定すると、データベース未保存のCustomerオブジェクトがデータベースに保存された場合でも、関連付けられたオブジェクトは自動的にデータベースに保存されなくなります。autosaveオプションの指定を省略した場合とは振る舞いが異なるので、注意してください。
  # ! autosave: true にしないと Customerオブジェクトが更新された際に関連付けられたオブジェクトは保存されない
  has_one :home_address, dependent: :destroy, autosave: true
  has_one :work_address, dependent: :destroy, autosave: true
  has_many :phones, dependent: :destroy
  # ¥ 20230814
  # - 記号->で Proc オブジェクトを作り、クラスメソッド has_many の第2引数に指定しています。この Proc オブジェクトは、関連付けの スコープ を示します。 Rails用語のスコープ（scope）は、モデルクラスの文脈では「検索の付帯条件」を意味します。9～10行の has_many メソッドは personal_phones という名前の関連付けを設定しています。基本的には、8行目で行われている関連付け phones と同様に Phone モデルと関連付けられています。ただし、個人電話番号だけを絞り込むために where(address_id: nil) という付帯条件を指定しています。 8～10 行の記述によりCustomerクラスには、phonesとpersonal_phonesという2 つのインスタンスメソッドが定義されます。前者は、顧客が持っているすべての電話番号（自宅電話番号、勤務先電話番号を含む）のリストを返します。後者は、顧客の個人電話番号（address_idカラムがNULLのレコード）だけを返します。 スコープには order(:id) のようなソート順も指定できます。フォームの中に電話番号が一定の順序で並ぶようにするためにこの指定を加えています。 なお、関連付け phones に autosave オプションが付いていないのは、自宅電話番号や勤務先電話番号の自動保存は Address モデル側で行われるからです。
  # ^ class_name: "Phone"：
  # ^ このオプションは、関連付けられたモデルの名前を指定します。アソシエーションの名前が personal_phones であっても、実際の関連モデルの名前は Phone です。
  has_many :personal_phones, -> {where(address_id: nil).order(:id)}, class_name: "Phone", autosave: true

  # ¥ inclusion: 値が特定のリストの中にあることを確かめる 20230813
  validates :gender, inclusion: { in: %w(male female), allow_blank: true }
  validates :birthday, date: {
    after: Date.new(1900, 1, 1),
    before: ->(obj) { Date.today },
    allow_blank: true
  }

  def password=(raw_password)
    if raw_password.kind_of?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
  end
end

#^ 20230814   has_many :personal_phones, -> {where(address_id: nil).order(:id)}, class_name: "Phone", autosave: true の説明:
# - 上記はRailsのアソシエーションです。具体的には、Customerモデルにhas_manyアソシエーションを定義しています。これはpersonal_phonesテーブルがあるという意味ではありません。代わりに、phonesテーブルを使用する関連付けです。

# 以下はその内訳です：
# - has_many :personal_phones： これはCustomerモデルにpersonal_phonesという名前の関連付けを作成しています。これにより、Customerモデルの任意のインスタンスでcustomer.personal_phonesを呼び出し、別のテーブルから関連レコードを取得することができます。

# -> { where(address_id: nil).order(:id) }： これはラムダ（無名関数）で、関連付けのスコープを設定します。この場合、address_idがnilであるphonesテーブルからレコードをフィルタリングし、idで並べ替えます。

# - class_name: "Phone"： これはRailsに、関連付けにどのモデル（ひいてはどのテーブル）を使うかを指示します。personal_phonesアソシエーションはPhoneモデルを使うということです。

# - autosave: true: trueに設定すると、Customerオブジェクトを保存するたびに、Railsは関連付けられたPhoneオブジェクトも（変更されていれば）自動的に保存します。

# ¥ もっと簡単に言うとphonesテーブルにはphoneレコードが格納されています。これらのレコードの中には、顧客の自宅や職場の住所に関連するものもあれば、どの住所にも関連しない（つまりaddress_idがnil）ものもあります。
# ¥ has_many :personal_phones アソシエーションを使用すると、指定された顧客のどの住所にも関連していないphoneレコードのみを取得する便利な方法が得られます。
# ¥ customer.personal_phonesを呼び出すと、Railsはphonesテーブルを検索して、特定の顧客のaddress_idがnilのレコードを取得し、id順に並べて返します。
# ¥ これは、RailsのActiveRecord関連付けのパワーと柔軟性を示すものです。関連付けにカスタムで意味のある名前をつけることで、関連付けられたレコードの特定のサブセットを簡単に取り出すことができます。

# ^ 20230813 通常の関数とsetterを使うときのタイミング:
#- セッター・メソッド： オブジェクトのプロパティや属性を明示的に設定する場合に使用します。標準的なRubyのイディオムと期待に沿ったものです。

# 通常のメソッド： 属性の設定」という型にはまらない操作を行う場合に使います。より複雑な操作を行う場合や、複数の引数を渡す場合などです。

#¥ 注意: Railsのようなフレームワークを使用している場合、モデル属性のセッターやゲッターを期待することがよくあります。これらをオーバーライドしたり、追加の動作を追加したりするには、通常セッター/ゲッターのアプローチが必要になります。

#- def password(raw_password) とした場合:
# あなたのコードは、Customerクラスのインスタンスに対してパスワード・メソッドを定義しています。このメソッド自体は、それ自身のロジックに基づいて必ずしもエラーを生成するわけではありません。しかし、設計から生じる可能性のある問題や混乱があります：

# メソッド名の混乱： メソッド名の混乱：通常、ユーザーモデルや顧客モデルでpasswordという名前のメソッドは、パスワードのゲッターであることが期待されますが、この場合はそうではありません。セッターのように使っているのです。これはコードを読む人を混乱させます。

# 設定と取得： 誰かがパスワードの値を取得しようとした場合（セキュリティ上の理由から、ハッシュ化されたパスワードを取得すべきではないにもかかわらず）、値を期待してcustomer.passwordを呼び出すかもしれませんが、その代わりに（引数が提供されていないため）nil値でパスワードを設定しようとするでしょう。

# hashed_passwordメソッドの欠落： self.hashed_password = ... を使用していますが、これは hashed_password= という名前の属性またはメソッドがあることを想定しています。 Customer モデルに hashed_password という名前のカラム/属性がないか、hashed_password のセッターメソッドがない場合、エラーが発生します。

# BCrypt の依存性： このメソッドは、BCrypt::Password.createが利用可能であることを前提としています。BCrypt gemがGemfileに追加されておらず、適切に要求されていない場合、このメソッドを呼び出すとエラーが発生します。

# 設計を改善するために

# 代わりにpasswordのセッターメソッドを使用します：
# ルビー
