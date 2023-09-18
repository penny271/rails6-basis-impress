class Customer::LoginForm
  #¥ ActiveModel::Modelモジュールをインクルードし、このクラスをActiveRecordモデル(データベースとのやりとりに使います)に似た振る舞いをするようにします。
  include ActiveModel::Model

  # ¥ 下記はそのままフォームのフィールド名になる 20230723
  attr_accessor :email, :password, :remember_me

  def remember_me?
    remember_me == "1"
  end
end

#¥ フォームオブジェクト = データベースと無関係なフォームを作成している
# 提供されたコードでは、Customer::LoginFormはActiveModel::Modelモジュールを含むプレーンなRubyクラスです。

# 各パーツが何をするかは以下の通りです：

# include ActiveModel::Model： この行はActiveModel::Modelモジュールをインクルードし、このクラスをActiveRecordモデル(データベースとのやりとりに使います)に似た振る舞いをするようにします。しかし、ActiveRecordモデルとは異なり、このクラスはデータベースに対応するテーブルを持ちません。これはしばしばフォームオブジェクトに使われます。フォームオブジェクトはデータの検証などを行うことができますが、データベースに保存する必要はありません。

# attr_accessor :email, :password: この行では、emailとpasswordの属性アクセサを定義しています。attr_accessorはRubyのメソッドで、同じ名前のインスタンス変数に対してゲッターメソッドとセッターメソッドを作成します。つまり、form.email = 'test@example.com'のような構文でこれらの属性を設定し、form.emailで取得することができます。

# このクラスはビューのフォームや、インスタンスを生成してフォーム送信を処理するコントローラの中で使用することができます。ActiveModel::Modelを含んでいるので、valid?やerrorsなどのメソッドを持っており、実際のActiveRecordモデルのインスタンスを生成したり更新したりする前に、フォームデータの検証を行うことができます。

# この方法は、フォームで送信されたデータがアプリケーションの ActiveRecord モデルと正確に一致しない場合に便利です。ユーザーログイン、複数ページのフォーム、その他の状況で使用できます。この例では、スタッフのログインフォームに使用しています。このフォームではメールアドレスとパスワードが必要ですが、これらをデータベースに永続化する必要はありません。