require "nkf"

# - 値の正規化 = ある規則に従うように情報を変換すること
# - バリデーション = ある属性の値が規則に従っているかどうかを検証すること - ※本ファイルは正規化する用
module StringNormalizer
  extend ActiveSupport::Concern

  def normalize_as_email(text)
    NKF.nkf("-W -w -Z1", text).strip if text
  end

  def normalize_as_name(text)
    NKF.nkf("-W -w -Z1", text).strip if text
  end

  def normalize_as_furigana(text)
    NKF.nkf("-W -w -Z1 --katakana", text).strip if text
  end

  def normalize_as_postal_code(text)
    NKF.nkf("-W -w -Z1", text).strip.gsub(/-/, "") if text
  end

  def normalize_as_phone_number(text)
    NKF.nkf("-W -w -Z1", text).strip if text
  end
end

# - nkf とは?
# NKF モジュールは日本語特有の各種変換機能を提供します。Rubyの標準ライブラリ nkf で定義されているので Gemfile に加える必要はなく、単にファイルの冒頭で require "nkf" と書けば利用可能となります。

# NKF モジュールの nkf メソッドは第1引数にフラグ文字列、第2引数に変換対象の文字列を取り、変換後の文字列を返します。ここで使用されているフラグの意味については 表14.1 をご覧ください。

#^ 表14.1: NKF#nkfメソッドの第１引数に指定できるフラグ フラグ 意味 -W 入力の文字コードをUTF-8と仮定する -w UTF-8で出力する -Z1 全角の英数字、記号、全角スペースを半角に変換する --katakana ひらがなをカタカナに変換する

# strip メソッドは文字列の先頭と末尾にある空白文字列を除去します

# ^ 20230806 extend ActiveSupport::Concern とは? ※このファイルでは使う必要なし クラスメソッドがないため
# ActiveSupport::ConcernはRailsが提供するモジュールで、モジュールの依存関係をきちんと宣言して再利用する方法を提供し、ポータブルでモジュール化された方法で属性やメソッド、その他のモジュールをバンドルすることができます。


# - # モジュール内で extend ActiveSupport::Concern を使用すると、インクルードされたメソッドが提供されます。通常、モジュールがインクルードされると、そのインスタンスメソッドがインクルード先のクラスに追加されます。ActiveSupport::Concernでは、インクルードされたブロック内のコードはクラスコンテキストで評価されるため、インスタンスメソッドだけでなくクラスメソッドも定義できます。

# また、あるモジュールが他のモジュールに依存していることを宣言する方法も提供します。モジュールAがモジュールBをインクルードし、モジュールBがActiveSupport::Concernをextendsした場合、モジュールAがインクルードされると、モジュールBのすべてのメソッド（クラスとインスタンスの両方）が自動的にモジュールAで利用できるようになります。

# 提供されたコードでは、StringNormalizerは文字列を正規化するモジュールです。extend ActiveSupport::Concernを使うことで、StringNormalizerを他のクラスやモジュールにインクルードすることができます。


module Greetable
  def greet
    "Hello!"
  end
end

class Person
  include Greetable
end

person = Person.new
puts person.greet  # => "Hello!"



module Announcer
  def announce
    "I'm a class method!"
  end
end

class Loudspeaker
  extend Announcer
end

puts Loudspeaker.announce  # => "I'm a class method!"