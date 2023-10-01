# ¥ 2.ch.12.2.1 タグ付け
# class CreateMessageTagLinks < ActiveRecord::Migration[6.0]
#   def change
#     create_table :message_tag_links do |t|

#       t.timestamps
#     end
#   end
# end

class CreateMessageTagLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :message_tag_links do |t|
      t.references :message, null: false
      t.references :tag, null: false

      t.timestamps
    end

    add_index :message_tag_links, [ :message_id, :tag_id ], unique: true
  end
end

# * リンクテーブル
# - 次に、メッセージとタグの関連を検討します。「１対多」、「多対1」、「多対多」のどれに当たるでしょうか。メッセージの側から見れば、１個のメッセージには複数のタグが付きます。逆にタグの側から見れば、１個のタグには複数のメッセージが付きます。典型的な多対多の関連です。リレーショナルデータベースにおいて多対多の関連をどう表現するか、というテーマについてはChapter6で詳しく説明しました。リンクテーブルというものを用意するのでしたね。Chapter6ではprogramsテーブルとcustomersテーブルを結び付けるリンクテーブルとしてentriesテーブルを定義しました。今回は、リンクテーブルとしてmessage_tag_linksテーブルを作りましょう。リンクテーブルの名前には特に決まりはありません。できればentriesのような、短くて分かりやすい名前が望ましいのですが、なかなかよい名前が見つからないこともあります。そのような場合、筆者は結び付けるテーブルをABC順に並べた上で、それぞれのテーブル名を単数形に変え、下線（_）で連結し、末尾に"_links"を加えるという規則で機械的にテーブルを作ることにしています。ただし、この方法にも難点があります。テーブル名が長くなりがちだということです。長すぎるテーブル名は扱いづらいので、私は名前の一部を省いたり、省略形を使ったりといった工夫をしています。message_tag_linksテーブルのマイグレーションスクリプトを生成します。