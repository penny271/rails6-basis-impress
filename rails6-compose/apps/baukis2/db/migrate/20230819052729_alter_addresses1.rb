class AlterAddresses1 < ActiveRecord::Migration[6.0]
  def change
    add_index :addresses, [ :type, :prefecture, :city ]
    add_index :addresses, [ :type, :city ]
    add_index :addresses, [ :prefecture, :city ]
    add_index :addresses, :city
  end
end

#  - 複合インデックス 2.ch3 20230819
# 複合インデックス 　一般に、X、Y、Zという3つのカラムに対して複合インデックスが設定されている場合、カラムX単独の検索、カラムXとY を組み合わせた検索、そして3つのカラムを組み合わせた検索で、この複合インデックスが活用されます。 　しかし、カラムY単独の検索、カラムZ 単独の検索、あるいはカラムYとZを組み合わせた検索では、この複合インデックスは利用されません。またカラムXとZ を組み合わせた検索では、カラムXに基づいてレコードを絞り込むところまではこの複合インデックスが利用されますが、そこからさらにカラムZ に基づいてレコードを絞り込む処理には利用されません。 　すべての組み合わせによる検索を最適化したければ、次の3つのインデックスを別途設定する必要があります。 カラムYとZに対する複合インデックス カラムXとZに対する複合
# カラムZに対するインデックス 　ただし、検索項目の数が増えてくると組み合わせの数は膨大になり、すべての組み合わせに対してインデックスを設定するのは現実的ではなく、適宜省略することになります。 customers テーブルの場合、例えば「誕生年」と「誕生日」を組み合わせた複合インデックスや「誕生月」と「誕生日」と「フリガナ（姓）」を組み合わせた複合インデックスは設定していません。

