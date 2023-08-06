class StaffEvent < ApplicationRecord
  # ¥ 下記のように書くことで type カラムから特別な意味が失われ、普通のカラムとして使用できることになります。
  self.inheritance_column = nil

  belongs_to :member, class_name: "StaffMember", foreign_key: "staff_member_id"
  # - # alias_attribute :occurred_at, :created_at： この行は、created_at属性のエイリアスを作成しています。つまり、staff_event.created_atを呼び出すと、staff_event.created_atと同じ値が返されます。
  alias_attribute :occurred_at, :created_at

  DESCRIPTIONS = {
    logged_in: "ログイン",
    logged_out: "ログアウト",
    logged_rejected: "ログイン拒否",
  }

  # ¥ 20230806
  # - StaffEventクラスでは、"logged_in"、"logged_out"、"logged_rejected "など、さまざまなタイプのスタッフイベントを保存するためにtypeカラムを使用します。descriptionメソッドは、これらのタイプを人間が読める説明に変換します。
  # ! type は  StaffEventテーブルの属性(列)であるため
  def description
    DESCRIPTIONS[type.to_sym]
  end
end


# ¥ 20230806
# モデル定義の中でこのように書けば、 type カラムから特別な意味が失われ、普通のカラムとして使用できることになります。

# ¥ 4行目では、 belongs_to メソッドを用いて、 StaffEvent モデルが member という名前で StaffMember モデルを参照することを宣言しています。この結果、インスタンスメソッド member が定義されます。インスタンス変数 @event に StaffEvent オブジェクトがセットされているとすれば、@event.member で記録と結び付けられた職員を参照することができます。

# ¥ foreign_key オプションには、外部キーの名前を指定します。デフォルトでRailsは関連付けの名前に_id を付けたものが外部キーの名前であると推測します。この推測から導き出せない場合は、 foreign_key オプションの指定が必要


# ^ chatGpt 解説 20230806
# - self.inheritance_column = nil： Railsでは、typeカラムはSingle Table Inheritance（STI）で使われる特別なカラムです。テーブルにtypeカラムがある場合、Railsは自動的にそれをSTI用のカラムとして扱います。RailsにtypeをSTIとして扱わせたくない場合は、このようにinheritance_columnをnilに設定することで無効にできます。この場合、typeは通常のカラムになります。

# - belongs_to :member, class_name: "StaffMember", foreign_key： "staff_member_id"： この行は、StaffEventモデルとStaffMemberモデルの関連付けを設定しています。各StaffEventレコードがStaffMemberレコードに属していることを示しています。class_nameオプションは関連付けられたモデルがStaffMemberであることを指定し、foreign_keyオプションはstaff_eventsテーブルのstaff_member_idカラムが各StaffEventがどのStaffMemberに属するかを追跡するために使用されることを示しています。


