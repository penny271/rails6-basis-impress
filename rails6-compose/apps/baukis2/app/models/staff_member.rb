class StaffMember < ApplicationRecord
  #  ¥ 20230806 app/controllers/concerns/string_normalizer.rbより
  # - 値の正規化 = ある規則に従うように情報を変換すること
  # - バリデーション = ある属性の値が規則に従っているかどうかを検証すること
  # include StringNormalizer
  # - 20230814 本ファイルの別のファイルで再利用できる部分抜き出している include PersonalNameHolderが before_validationや validatesを行う
  include EmailHolder # ^ emailのバリデーション
  include PersonalNameHolder  # ^ 名前関連のバリデーション
  include PasswordHolder # ^ passwordのバリデーション

  # ¥ 20230806 一対多の関連付け
  # ¥ クラスメソッド has_many は一対多の関連付けを設定します。引数に指定されたシンボルが関連付けの名前となります。このシンボルと同名のインスタンスメソッドが定義されるので、関連付けの名前は既存の属性やインスタンスメソッドの名前と被らないように選択する必要があります。 class_name オプションには、関連付けの対象モデルのクラス名を指定します。関連付けの名前からクラス名が推定できる場合は class_name オプションは省略可能です。
  # ^ dependent オプションには、 StaffMember オブジェクトを削除する際の処理方法を指定します。シンボル:destroy を指定すれば、関連付けられたすべての StaffEvent オブジェクトが StaffMember オブジェクトが削除される前に削除される
  has_many :events, class_name: "StaffEvent", dependent: :destroy

  #  - モデルオブジェクトに対してバリデーション、保存、削除などの操作が行われる前後に実行される処理を コールバック（callbacks）または フック（hooks）と呼びます。ここで使用されている ActiveRecord::Base のクラスメソッド before_validation は、指定されたブロックをバリデーションの直前に実行されるコールバックとして登録します。すなわち、 StaffMember オブジェクトに対してバリデーションが行われる直前に、下記のコードが実行されます。
  # before_validation do
    # self.email = normalize_as_email(email)
    # self.family_name = normalize_as_name(family_name)
    # self.given_name = normalize_as_name(given_name)
    # self.family_name_kana = normalize_as_furigana(family_name_kana)
    # self.given_name_kana = normalize_as_furigana(given_name_kana)

  # HUMAN_NAME_REGEXP = /\A[\p{han}\p{hiragana}\p{katakana}\u{30fc}A-Za-z]+\z/
  # # - 1個以上のカタカナ文字列にマッチする正規表現を定数 KATAKANA_REGEXP にセットしている
  # KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/

  #  ¥ 20230809 valid_email_2 gem を使い、 email属性をvalidatesするよう指示している。 email": true
  # By setting "valid_email_2/email": true, you're activating the validation provided by the valid_email_2 gem for the email attribute.
  # validates :email, presence: true, "valid_email_2/email": true, uniqueness: {case_sensitive: false}

  # ! 20230806 validation失敗時のhtmlの反応
  #- フォームから送信されたデータのバリデーションが失敗した場合、Railsはフォームを再表示する際に自動でラベルと入力フィールドを <div class="field_with_errors"> と </div> で囲みます。ラベルの文字色を赤色、入力フィールドの背景色をピンク色に指定する <= scss

  # - 20230806 validateメソッド
  # ¥ 20230806 値が空(tabや空白も)のときに失敗
  # validates :family_name, :given_name, presence: true, format: { with: HUMAN_NAME_REGEXP, allow_blank: true, format: { with: HUMAN_NAME_REGEXP, allow_blank: true}}
  # ¥ family_name_kana 属性と given_name_kana 属性に対しては2種類のバリデーションを行います。1つ目はすでに説明した presence バリデーションです。2つ目は値が正規表現にマッチするかどうかを調べる format バリデーションです。 format オプションの値に指定したハッシュの中で、このバリデーションの詳細設定を記述します。 with オプションには正規表現を指定します。 allow_blank オプションに true を指定すると、値が空の場合にはバリデーションをスキップします。
  # validates :family_name_kana, :given_name_kana, presence: true, format: { with: KATAKANA_REGEXP, allow_blank: true }

  #  ¥ Gem date_validator で バリデーション
  validates :start_date, presence: true, date: {
    after_or_equal_to: Date.new(2000, 1, 1),
    before: -> (obj) { 1.year.from_now.to_date },
    allow_blank: true
  }
  validates :end_date, date: {
    after: :start_date,
    before: -> (obj) { 1.year.from_now.to_date },
    allow_blank: true
  }

  # ¥ Proc オブジェクト = 無名関数 を使う訳 20230806:
  # -   -> は Proc オブジェクトを生成する記号です。 Proc オブジェクトとは「名前のない関数」です。括弧の中の obj が関数への引数で、この StaffMember オブジェクト自体がこの引数にセットされます（ただし、この例では関数の中で利用されていません）。
  # ! NG   before: 1.year.from_now.to_date
  #- しかし、これは予想外の結果を引き起こします。Baukis2を production モードで動作させた場合、起動時に1回だけクラスの読み込みが行われます。そのため、この before キーの値は起動時を基準として1年後の日付に固定されてしまいます。つまり、2020年4月1日にBaukis2を起動すれば、今日の日付が変わってもアプリケーションが再起動されるまで「2021年4月1日よりも前」という規則に従ってバリデーションが行われることになります。したがって、20行目は必ず Proc オブジェクトを指定しなければなりません。

  # def password=(raw_password) #! =(raw_password) セッター 属性の値を変えるのに必要
  #   if raw_password.kind_of?(String)
  #     self.hashed_password = BCrypt::Password.create(raw_password)
  #   elsif raw_password.nil?
  #     self.hashed_password = nil
  #   end
  # end

  # ¥ 20230806 Rubyでは、メソッド名の最後にクエスチョンマーク「? これは、メソッドが真偽値を返すことを示すために使われます。これは、コードをより読みやすく、表現豊かにするための方法です。
  def active?
    # ¥ Rubyではsuspendedとsuspended?は別のメソッドとして扱われます。suspended?メソッドは通常、StaffMemberがサスペンドされているかどうかを示す真偽値(trueまたはfalse)を返します。
    #! 結論: !suspended も真偽値を返す限り可能であるが、 !suspended? とするほうがより一般的で booleanを返すとわかりやすい
    #¥ Railsでは、モデル内に（suspendedのような）ブール値のカラムがある場合、Railsは自動的に属性と同じ名前の述語メソッドを作成し、クエスチョンマーク（?）をつける。
    # ¥ つまり、StaffMemberモデルにsuspended属性(boolean)がある場合(そしてこの属性がデータベースでbooleanフィールドとして定義されている場合)、Railsは自動的にsuspended属性の値に基づいてtrueまたはfalseを返すsuspended?メソッドを提供します。よって !suspended? メソッドを使うことができる!! 同様に !suspended も可能。
    !suspended? && start_date <= Date.today && (end_date.nil? || end_date > Date.today)
  end
end


#¥ def password=(raw_password) の意味 20230723:
# これはRubyでは「セッター」メソッドと呼ばれる特別なメソッドである。このメソッドを使うと、オブジェクトの属性の値を設定することができる。

# Rubyでは、インスタンス変数に対してセッターメソッドとゲッターメソッドを定義することができる。ゲッター・メソッドはインスタンス変数の値を返し、セッター・メソッドはインスタンス変数の値を設定する。

# def password=(raw_password)という構文は、password属性のセッター・メソッドを定義しています。メソッド名の = が、これをセッター・メソッドにしています。このメソッドは、raw_passwordという1つの引数を取り、それに対して何らかの処理を行います。

# ^ この特定のコード・スニペットでは、password= メソッドは StaffMember インスタンスの password 属性のカスタム・セッターです。これは、プレーンテキストのパスワードが指定された場合に、ハッシュ化された値を hashed_password 属性に代入するために使用されます。

# このメソッドの内部で実行されるコードは次のとおりです：

# raw_password が文字列の場合、BCrypt を使用してパスワードをハッシュし、そのハッシュ値を hashed_password に割り当てます。
# raw_password が nil の場合、hashed_password を nil に設定します。

#¥ 下記のように呼び出す
# staff_member = StaffMember.new
# staff_member.password = "my_password" # This will call the `password=` method
