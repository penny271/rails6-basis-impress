module PersonalNameHolder
  extend ActiveSupport::Concern

  HUMAN_NAME_REGEXP = /\A[\p{han}\p{hiragana}\p{katakana}\u{30fc}A-Za-z]+\z/
  KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/

  # ¥ このブロックの中にメソッドを定義しておくとモジュールがincludeされたあとににそのメソッドが動作する
  #- included do .. end ブロックに定義した処理を include する側のクラスのコンテキストで実行する

  # ¥ Rubyでモジュールをインクルードすると、通常、そのインスタンスメソッドだけが、インクルードしたクラス/モジュールのインスタンスメソッドとして利用できるようになります。クラスレベルのメソッドやディレクティブ（before_validationなど）を追加したい場合は、少し異なるアプローチが必要です。

  # ¥ ActiveSupport::Concernは、includedメソッドを提供することで、これを扱うよりエレガントな方法を提供します。この方法では、簡単にクラスレベルのメソッドを追加したり、コールバックを設定したり、モジュール内でバリデーションを定義することができます。

  # 以下はその内訳です：
  # インスタンスメソッド： included  do ... end ブロックの外側でモジュール内で定義されたメソッドは、このモジュールをインクルードしているクラス/モジュールのインスタンスメソッドになります。

  # - クラスメソッド/ディレクティブ： included do ... endブロックの中のメソッドは、このモジュールを含むクラス/モジュールのコンテキストで実行されます。つまり、この場合、before_validation と validates ディレクティブは PersonalNameHolder を含むクラス/モジュールに対して設定されます。

  # before_validationブロック内でのself.の使用は、included do ... endの使用とは無関係です。ブロック内の self.は、PersonalNameHolder を含み、検証中のクラス/モジュールのインスタンスを指します。これは、その属性にアクセスして変更するために使用されます。

  included do
    include StringNormalizer

    before_validation do
      self.family_name = normalize_as_name(family_name)
      self.given_name = normalize_as_name(given_name)
      self.family_name_kana = normalize_as_furigana(family_name_kana)
      self.given_name_kana = normalize_as_furigana(given_name_kana)
    end

    validates :family_name, :given_name, presence: true,
      format: { with: HUMAN_NAME_REGEXP, allow_blank: true }
    validates :family_name_kana, :given_name_kana, presence: true,
      format: { with: KATAKANA_REGEXP, allow_blank: true }
  end
end

#- 先に示したPersonalNameHolderモジュールでは、includingクラスに追加する必要があるクラスレベルの設定（before_validationコールバックやバリデーションなど）がありました。includedブロックが使われたのはそのためです。

#- まとめると、ActiveSupport::Concernを使うモジュールが、Rails固有のディレクティブやコンフィギュレーションを使わずにインスタンス（あるいはクラス）メソッドだけを定義する場合は、includedブロックは必要ありません。クラスレベルの設定を追加する場合は、includedブロックを使うことになります。