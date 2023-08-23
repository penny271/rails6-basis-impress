class Administrator < ApplicationRecord
  include EmailHolder # ^ 20230814 emailのバリデーション
  include PasswordHolder # ^ 1.ch17 パスワードが入力された際にhashed_password属性にその値をハッシュ化して設定する※保存はこのときにはできていない。object.save! する必要あり

  # ¥ 20230814 他のファイルで再利用できるように module化する
  # def password=(raw_password)
  #   if raw_password.kind_of?(String)
  #     self.hashed_password = BCrypt::Password.create(raw_password)
  #   elsif raw_password.nil?
  #     self.hashed_password = nil
  #   end
  # end
end

# - attr_accessorが不要な理由:
#- Rubyのattr_accessorメソッドは、与えられたインスタンス変数に対してゲッターとセッターの両方を定義する便利なメソッドです。これは、データベースに永続化されない属性、特にプレーンなRubyオブジェクトによく使われます。

#- 提供された Administrator クラスでは、カスタム・セッター・メソッド password= を定義していますが、対応するゲッター・メソッド (password) はありません。このカスタム・セッターは、提供されたraw_passwordを処理してハッシュし、それをhashed_password属性に割り当てます。

#- パスワードにattr_accessorを使っていないのは、次の理由からです：

#- 汎用セッターは必要なく、カスタムセッター（password=）があるからです。
