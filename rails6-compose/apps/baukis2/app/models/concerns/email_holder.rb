module EmailHolder
  extend ActiveSupport::Concern

  included do
    include StringNormalizer

    before_validation do
      self.email = normalize_as_email(email)
    end

    validates :email, presence: true, "valid_email_2/email": true,
      uniqueness: { case_sensitive: false }
  end
end

#- included do ... end の説明 20230814
  # ¥ このブロックの中にメソッドを定義しておくとモジュールがincludeされたあとににそのメソッドが動作する
  #- included do .. end ブロックに定義した処理を include する側のクラスのコンテキストで実行する

  # ¥ Rubyでモジュールをインクルードすると、通常、そのインスタンスメソッドだけが、インクルードしたクラス/モジュールのインスタンスメソッドとして利用できるようになります。クラスレベルのメソッドやディレクティブ（before_validationなど）を追加したい場合は、少し異なるアプローチが必要です。

  # ¥ ActiveSupport::Concernは、includedメソッドを提供することで、これを扱うよりエレガントな方法を提供します。この方法では、簡単にクラスレベルのメソッドを追加したり、コールバックを設定したり、モジュール内でバリデーションを定義することができます。

  # 以下はその内訳です：
  # インスタンスメソッド： included  do ... end ブロックの外側でモジュール内で定義されたメソッドは、このモジュールをインクルードしているクラス/モジュールのインスタンスメソッドになります。

  # - クラスメソッド/ディレクティブ： included do ... endブロックの中のメソッドは、このモジュールを含むクラス/モジュールのコンテキストで実行されます。つまり、この場合、before_validation と validates ディレクティブは PersonalNameHolder を含むクラス/モジュールに対して設定されます。

  # before_validationブロック内でのself.の使用は、included do ... endの使用とは無関係です。ブロック内の self.は、PersonalNameHolder を含み、検証中のクラス/モジュールのインスタンスを指します。これは、その属性にアクセスして変更するために使用されます。
