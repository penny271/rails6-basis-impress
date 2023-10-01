# ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロック
# class CreateHashLocks < ActiveRecord::Migration[6.0]
#   def change
#     create_table :hash_locks do |t|

#       t.timestamps
#     end
#   end
# end

class CreateHashLocks < ActiveRecord::Migration[6.0]
  def change
    create_table :hash_locks do |t|
      t.string :table, null: false
      t.string :column, null: false
      t.string :key, null: false

      t.timestamps
    end

    add_index :hash_locks, [ :table, :column, :key ], unique: true
  end
end

# * Chapter8においてはprogramsテーブルとentriesモデルが１対多で関連付けられており、entriesテーブルに制限数を超えたレコードが追加されないように、programsテーブルの１つのレコードに対して排他的ロックを取得しました。
# * しかし、今回はtagsテーブルに設定されている一意制約が問題の鍵です。ある職員がXというタグを新規追加したいという状況において、他の職員がXというタグを追加するのを阻止しなければなりません。何に対して排他的ロックを取ればいいのでしょうか。このような場合のひとつの解決策は、排他制御のための専用テーブルを作ることです。 => hash_locksテーブルの作成
