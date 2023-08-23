class AlterCustomers1 < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :birth_year, :integer
    add_column :customers, :birth_month, :integer
    add_column :customers, :birth_mday, :integer

    add_index :customers, [ :birth_year, :birth_month, :birth_mday ]
    add_index :customers, [ :birth_month, :birth_mday ]
    add_index :customers, :given_name_kana
    add_index :customers, [ :birth_year, :family_name_kana, :given_name_kana ],
      name: "index_customers_on_birth_year_and_furigana"
    add_index :customers, [ :birth_year, :given_name_kana ]
    add_index :customers,
      [ :birth_month, :family_name_kana, :given_name_kana ],
      name: "index_customers_on_birth_month_and_furigana"
    add_index :customers, [ :birth_month, :given_name_kana ]
    add_index :customers, [ :birth_mday, :family_name_kana, :given_name_kana ],
      name: "index_customers_on_birth_mday_and_furigana"
    add_index :customers, [ :birth_mday, :given_name_kana ]  end
end

# ¥ 2.ch3 20230819
# add_index メソッドに name オプションを付けて、インデックスの名前を指定しています。 　データベーステーブルのインデックスには名前が必要なのですが、 add_index メソッドはデフォルトでテーブル名とカラム名を組み合わせてインデックス名を生成するので、通常私たちがインデックス名を意識することはありません。しかし、インデックス名の長さには制限（PostgreSQLでは63バイト）があるため、複合インデックスとして組み合わせるカラムの個数が増えるとこの制限を超えることがあります。このような場合には、 name オプションを用いてインデックス名を指定する必要があります。 　 add_index メソッドが生成するインデックス名は、次の手順で作られます。 "index_"、テーブル名、"_on_" を連結する。 単独のインデックスであればカラム名を追加する。 複合インデックスであれば、すべてのカラム名を "_and_" で連結して追加する。 　したがって、3個のカラムを用いた複合インデックスを設定する場合、テーブル名とカラム名の長さの合計が63文字を超えるとPostgreSQLで文字数オーバーとなります

