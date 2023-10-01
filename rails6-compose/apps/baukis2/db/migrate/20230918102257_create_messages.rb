# ¥ 2.ch.10.1.2 Ajax 問い合わせ管理機能
# - この messages テーブルでは、単一テーブル継承（本編Chapter 16参照）の仕組みを利用します。そのため文字列型の type カラムを定義しています。 単一テーブル継承は、オブジェクト指向プログラミングの継承概念をリレーショナルデータベースで擬似的に実現する方法です。Ruby on Railsでは type カラム（あるいは、モデルクラスの inheritance_column 属性に指定されたカラム）にクラス名を記録することで、単一テーブル継承を実現しています。root_id カラムと parent_id カラムは、メッセージのツリー構造を表現するために用います。起点となる顧客からの問い合わせをルート（ root）と呼びます。そして、問い合わせと返信の間の関係を親子の関係として表します。

# - 問い合わせは返信にとっての親であり、返信は問い合わせにとっての子となります。 24行目の name オプションについては、既に3-1-2項「データベーススキーマの見直し」で説明をしています。 マイグレーションを実行します
class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :customer, null: false               # 顧客への外部キー
      t.references :staff_member                        # 職員への外部キー
      t.integer :root_id                                # Messageへの外部キー(顧客から)
      t.integer :parent_id                              # Messageへの外部キー
      t.string :type, null: false                       # 継承カラム
      t.string :status, null: false, default: "new"     # 状態（職員向け）
      t.string :subject, null: false                    # 件名
      t.text :body                                      # 本文
      t.text :remarks                                   # 備考（職員向け）
      t.boolean :discarded, null: false, default: false # 顧客側の削除フラグ
      t.boolean :deleted, null: false, default: false  # 職員側の削除フラグ

      t.timestamps
    end

    add_index :messages, [ :type, :customer_id ]
    add_index :messages, [ :customer_id, :discarded, :created_at ]
    add_index :messages, [ :type, :staff_member_id ]
    add_index :messages, [ :customer_id, :deleted, :created_at ]
    add_index :messages, [ :customer_id, :deleted, :status, :created_at ],
      name: "index_messages_on_c_d_s_c"
    add_index :messages, [ :root_id, :deleted, :created_at ]
    add_foreign_key :messages, :customers
    add_foreign_key :messages, :staff_members
    add_foreign_key :messages, :messages, column: "root_id"
    add_foreign_key :messages, :messages, column: "parent_id"
  end
end
