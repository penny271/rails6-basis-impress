class StaffMember < ApplicationRecord
  def password=(raw_password) #! =(raw_password) セッター 属性の値を変えるのに必要
    if raw_password.kind_of?(String)
      self.hashed_password = BCrypt::Password.create(raw_password)
    elsif raw_password.nil?
      self.hashed_password = nil
    end
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
