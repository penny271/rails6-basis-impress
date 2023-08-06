# class CreateStaffEvents < ActiveRecord::Migration[6.0]
#   def change
#     create_table :staff_events do |t|

        # ! created_at と updated_at カラムを追加する
#       t.timestamps
#     end
#   end
# end

class CreateStaffEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_events do |t|
      t.references :staff_member, null: false, index: false, foreign_key: true
          # 職員レコードへの外部キー
      t.string :type, null: false # イベントタイプ
      t.datetime :created_at, null: false # 発生時刻
    end

    add_index :staff_events, :created_at
    add_index :staff_events, [ :staff_member_id, :created_at ]
  end
end

# ¥20230806
# - TableDefinition オブジェクトの references メソッドは、指定された名前の末尾に_id を追加し、その名前（つまり staff_member_id）を持つ整数型のカラムを定義します。 このカラムの値は staff_members テーブルの主キー（ id）を参照しており、このカラムを通じて staff_members テーブルと staff_events テーブルの間に一対多の関連付けが生まれます。

#  さて、4行目で index オプションが使われています。 references メソッドはデフォルトでカラムにインデックスを設定します。しかし、ここで定義される staff_member_id カラムに関しては11行目で複合インデックスを設定するので、無駄を省くためインデックスを設定していません。

# - さらに、4行目では foreign_key オプションが使われています。このオプションに true を指定すると、 references メソッドは staff_members テーブルと staff_events テーブルの間に外部キー制約を設定し

