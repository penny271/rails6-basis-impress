class CreateStaffMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_members do |t|
      #! null: false で NON NULL制約を課している
      t.string :email, null: false                      # メールアドレス
      t.string :family_name, null: false                # 姓
      t.string :given_name, null: false                 # 名
      t.string :family_name_kana, null: false           # 姓（カナ）
      t.string :given_name_kana, null: false            # 名（カナ）
      #! passwordをハッシュ化 null制約なし
      t.string :hashed_password                         # パスワード
      t.date :start_date, null: false                   # 開始日
      t.date :end_date                                  # 終了日
      t.boolean :suspended, null: false, default: false # 無効フラグ

      t.timestamps
    end

    #  インデックスの設定
    add_index :staff_members, "LOWER(email)", unique: true
    add_index :staff_members, [ :family_name_kana, :given_name_kana ] # 複合インデックス
  end
end

#¥ 20230723
#¥ ブロック変数 t には TableDefinitionオブジェクト がセットされます。このオブジェクトの各種メソッドを呼び出すことでテーブルの定義を行います。初期状態では timestamps メソッドだけが記述されています。これは created_at と updated_at という名前を持つ日時型のカラムをテーブルに追加するメソッドです。この2つのカラムはRailsがレコードの作成時刻と最終変更時刻を記録するために使用します
