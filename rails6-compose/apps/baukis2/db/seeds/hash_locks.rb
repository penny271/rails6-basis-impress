# ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロック
256.times do |i|
  HashLock.create!(table: "tags", column: "value", key: sprintf("%02x", i))
end

# ブロック変数iには0から255までの値がセットされます。式sprintf("%02x",i)は、2桁の１６進数"00"〜"ff"を文字列として返します。