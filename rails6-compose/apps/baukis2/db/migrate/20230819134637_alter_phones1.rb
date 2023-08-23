class AlterPhones1 < ActiveRecord::Migration[6.0]
  def change
    add_index :phones, "RIGHT(number_for_index, 4)"
  end
end

# ¥ 20230819
# RIGHT関数は、文字列の右側から指定された文字数を返すSQL関数です。

# この文脈では

# number_for_indexです： おそらく、これは電話番号または文字列を含むPhonesテーブルのカラムです。
# 4: これは、number_for_index文字列の右側から何文字取得したいかを示します。
# つまり、RIGHT(number_for_index, 4)という式は、number_for_indexカラムの最後の4文字を取得します。