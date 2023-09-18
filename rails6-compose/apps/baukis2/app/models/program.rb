# 2.ch6.1.3
# ¥ Program モデルと Entry モデルの間に「１対多の関連付け」を設定しています。 Entry モデルは Program モデルと Customer モデルを連結する役割を持ちますので、リンクモデルと呼びます。 続いて、3行目をご覧ください。 has_many :applicants, through: :entries, source: :customer ここで Program モデルと Customer モデルの間に「多対多の関連付け」を設定しています。 このコードを一般化したものが次の式です。
# -  has_many X, through: Y, source: Z


class Program < ApplicationRecord
  # has_many :entries, dependent: :destroy
  # ¥ 2.ch.7 章末問題
  has_many :entries, dependent: :restrict_with_exception
  # - 多対多の関連付け
  # * has_many メソッドの引数の単数形が source オプションの値と等しい場合、 source オプションは省略できます なので、省略不可
  #  - applicants アソシエーションは、ActiveRecordが提供する多対多のリレーションシップを扱うための便利な方法であることを覚えておいてください。これはデータベースの直接のカラムやテーブルに対応するものではありません。その代わりに、定義したリレーションシップを使って関連するレコードを取得します。
  has_many :applicants, through: :entries, source: :customer
  # - Association Name: ： アソシエーションの名前はregistrantである。これは単にアソシエーションを参照するための名前であり、データベースのテーブル名やカラム名に直接対応する必要はない。
  # データベースカラム： Railsは、プログラムテーブルにregistrant_idという外部キーカラムがあり、リレーションシップを保持していると仮定します。このカラムには、プログラムが"belongs to"StaffMemberのIDが含まれている必要があります。
  # class_nameオプション： class_name: "StaffMember "を使用すると、registrantの関連付けがStaffMemberモデルのレコードを探すようにRailsに指示することになります。これは、アソシエーションの名前（registrant）と関連付けられたモデルの名前（StaffMember）が一致しない場合に便利です。
  #! association名は :registrant である必要がある。 StaffMemberが持っている関連付けたいカラム名が registrant_id であるため、 _id の前の部分の名称を揃える必要あり!!
  belongs_to :registrant, class_name: "StaffMember"

  # ¥ 2.ch6.3.1
  # * クラスメソッド scope を用いて :listing という名前のスコープを定義しています。モデルクラスのスコープとは、検索条件の組み合わせに名前を付けたものです。 scope メソッドの第2引数は Proc オブジェクトで、その中に where、 order、 includes などの検索条件を指定するメソッドを記述します。
  # ¥ .includes()で N+1問題を対処している
  # scope :listing, -> {
  #   order(application_start_time: :desc).includes(:registrant)
  # }

  # ¥ 2.ch6.3.4 さらにN+1問題を対処
  #  ! 現行のコードでは、プログラムの申込者数をプログラムごとに数えています。つまり、10件のプログラムを表示するために、10回データベースに申込者数を数えさせていることになります。要するに、ここにも「N+1問題」が存在します。1回のクエリで10件分の申込者数を取得できないものでしょうか? 下記回答
  # * joins メソッドは別のテーブルを結合します。すなわち、そのテーブルの値を検索結果に取り込みます。
  # - 引数には、関連付けの名前を指定します。ここでは :entries を指定することで、 entries テーブルを結合しています。 シンボル :entries はテーブルの名前ではなく、 Program モデルでクラスメソッド has_many により定義された関連付けの名前です。
  # * select メソッドの引数には、テーブルから値を取得するカラムのリストをコンマ区切りで指定します。ドットの左側がテーブル名で右側がカラム名です。アスタリスク（*）は「すべてのカラム」という意味です。 select メソッドを用いない場合、テーブルから単純にすべてのカラムの値を取得します。つまり、 select メソッドを用いないことと、"programs.*" という引数を与えて select メソッドを呼び出すことは、同じ意味です。ここでは、 programs テーブルのすべてのカラムの値に加え、 COUNT(entries.id) AS number_of_applicants という値を取得するように指定しています。SQLの関数 COUNT は引数に指定したカラムの値がNULLでないレコードの個数を返します。 entries テーブルの id カラムにはNOT NULL制約が課せられていますので、結局のところ entries テーブルのレコード数を数えているのと同じです。そして、SQLの演算子ASは左辺の値に別名を付けますので、私たちは number_of_applicants という“カラム”として、 entries テーブルのレコード数を得ることになります。 select メソッドで指定したカラムのリストに COUNT のような集計関数が含まれている場合、原則として group メソッドの呼び出しが必須となります。 COUNT 関数はレコードの集合をグループに分けて、グループごとにレコード数を数え上げます。 group メソッドはグループ化の基準となるカラムを設定します。ここでは group メソッドに引数として "programs.id" が指定されており、 COUNT 関数の引数には entries.id がされています
  # * ここでは group メソッドに引数として "programs.id" が指定されており、 COUNT 関数の引数には entries.id がされていますので、 entries テーブルの全レコードがカラム program_id を基準にグループに分けられます。

  # - programs テーブル(左辺)とentries テーブル(右辺)を結合している
  scope :listing, -> {
    # ! 参照されてないレコードを含まない検索結果を返すテーブルケグ等 - 0件の申込みは含まない 今回適さない
    # joins(:entries)
    # - joins メソッドを left_joins メソッド（あるいは、別名の left_outer_joins メソッド）で置き換えると、結合する側のテーブル（左辺）のレコードはすべて（右辺から参照されていなくても）検索結果に残るようになります。これをSQL用語で左外部結合（LEFT OUTER JOIN）と呼びます
    left_joins(:entries)
    .select("programs.*, COUNT(entries.id) AS number_of_applicants")
    .group("programs.id")
    .order(application_start_time: :desc)
    .includes(:registrant)
  }

  # ¥ 2.ch.8.1.3 プログラム一覧表示・詳細表示機能(顧客向け)
  scope :published, -> {
    where("application_start_time <= ?", Time.current).order("application_start_time DESC")
  }


  # ¥ 2.ch7.12 仮想フィールド validationの対象となる 型の指定ができる DBに保存はされない
  # Program モデルが受け付け開始日時および受け付け終了日時の日付、時間、分の値を一時的に保持できるようにします
  # ¥ Railsが提供するクラスメソッド attribute は、モデルクラスにインスタンス変数を読み書きするメソッドを追加します。すなわち、モデルクラスに読み書き可能な属性を定義します。14行目をご覧ください。 attribute :application_start_date, :date, default: Date.today 日付型の属性 application_start_date を定義しています。そのデフォルト値は今日の日付となります。Ruby標準のクラスメソッド attr_accessor でも同様に属性を定義できますが、 attribute で定義された属性には型が設定される点に特徴があります。例えば、ある属性に整数（integer）という型を設定すれば、書き込みメソッドの引数に与えられた文字列は暗黙の内に整数に変換されます。これは、HTMLフォームから送られてくる値を処理するのに適した特徴です。本書では、クラスメソッド attribute で定義された属性を 仮想フィールド と呼ぶことにします。モデルクラスにおいて仮想フィールドはデータベーステーブルのカラムに対応する通常のフィールドと同様に扱えます。つまり、バリデーションの対象となります。ただし、通常のフィールドとは異なり、仮想フィールドの値はデータベースに保存されません
  attribute :application_start_date, :date, default: Date.today
  attribute :application_start_hour, :integer, default: 9
  attribute :application_start_minute, :integer, default: 0
  attribute :application_end_date, :date, default: Date.today
  attribute :application_end_hour, :integer, default: 17
  attribute :application_end_minute, :integer, default: 0

  def init_virtual_attributes
    if application_start_time # - programsテーブルにある属性名(列名)
      self.application_start_date = application_start_time.to_date
      self.application_start_hour = application_start_time.hour
      self.application_start_minute = application_start_time.min
    end

    if application_end_time # - programsテーブルにある属性名(列名)
      self.application_end_date = application_end_time.to_date
      self.application_end_hour = application_end_time.hour
      self.application_end_minute = application_end_time.min
    end
  end

  # ¥ 2.ch7.2.1
  before_validation :set_application_start_time
  before_validation :set_application_end_time

  # ¥ pplication_start_date の値が nil でなければ、 Date オブジェクトの in_time_zone メソッドで日時オブジェクト（ ActiveSupport::TimeWithZone オブジェクト）に変換し、変数 t にセットします。そして、 advance メソッドでその t を前に進めることにより、時と分をセットしています。 2番目のメソッド set_application_end_time でもほぼ同様の処理が行われています
  private def set_application_start_time
    # .in_time_zoneメソッドの結果（現在のタイムゾーンに調整されたTimeまたはDateTimeオブジェクト）は、
    # 変数tに代入される。
    # - in_time_zoneを使用して日付を時刻に変換すると、デフォルトの時刻コンポーネントは真夜中（00:00:00）に設定されます。したがって、日付だけ（時間要素なし）から始めて時刻に変換した場合、最初の時刻は使用しているタイムゾーンの00:00:00になります。
    if t = application_start_date&.in_time_zone
      self.application_start_time = t.advance(
        hours: application_start_hour,
        minutes: application_start_minute
      )
    end
  end

  private def set_application_end_time
    if t = application_end_date&.in_time_zone
      self.application_end_time = t.advance(
        hours: application_end_hour,
        minutes: application_end_minute
      )
    end
  end

  # ¥ 2.ch7.2.2 ※ validationするための翻訳ファイルの編集及び再起動が必要
  # config/locales/models/program.ja.yml
  validates :title, presence: true, length: { maximum: 32 }
  validates :description, presence: true, length: { maximum: 800 }
  validates :application_start_time, date: {
    after_or_equal_to: Time.zone.local(2000, 1, 1),
    before: -> (obj) { 1.year.from_now },
    allow_blank: true
  }
  # * 58-68行では、 date タイプのバリデーションを用いて application_start_time 属性と application_end_time 属性の値をチェックしています。これらの属性は日時型であり日付型ではありませんが、 date タイプのバリデーションが利用可能です。
  # ! date タイプのバリデーションはRails標準の機能ではなく、本編Chapter 3で導入したGemパッケージ date_validator が提供する機能です。67行目をご覧ください。
  # - if: -> (obj) { obj.application_start_time } if オプションを用いて、バリデーションの実施条件を指定しています。 Procオブジェクトの戻り値が偽であれば、64-66行で記述されている application_end_time 属性に対するバリデーションは行われません。
  # * Proc オブジェクトへの引数 obj は、この Program オブジェクト自身を指しています。つまり、申し込み開始日時がセットされていなければ、申し込み終了日時に関するバリデーションはスキップされます。 69-74行では、 min_number_of_participants 属性の値が max_number_of_participants 属性の値よりも大きい場合にエラーを登録しています。
  validates :application_end_time, date: {
    after: :application_start_time,
    before: -> (obj) { obj.application_start_time.advance(days: 90) },
    allow_blank: true,
    # - 下記の if は validates :application_end_time, date:全体にかかっている
    if: -> (obj) { obj.application_start_time }
  }
  validates :min_number_of_participants, :max_number_of_participants,
    numericality: {
    only_integer: true, greater_than_or_equal_to: 1,
    less_than_or_equal_to: 1000, allow_nil: true
  }
  validate do
    if min_number_of_participants && max_number_of_participants &&
        min_number_of_participants > max_number_of_participants
      errors.add(:max_number_of_participants, :less_than_min_number)
    end
  end

  # ¥ 2.ch.7 章末問題
  def deletable?
    entries.empty?
  end
end

# * Using the Association: To retrieve the customers (applicants) for a program, you'd use:
# program = Program.find(id)
# program.applicants