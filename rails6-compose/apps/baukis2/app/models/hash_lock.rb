# ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロック
class HashLock < ApplicationRecord
  class << self
    # * .lock(true) で 排他的ロックしている
    def acquire(table, column, value)
      HashLock.where(table: table, column: column,
        key: Digest::MD5.hexdigest(value)[0,2]).lock(true).first!
    end
  end
end

# *このメソッドはテーブル名、カラム名、値という3つの引数を取ります。5行目にある次の式に注目してください。 Digest::MD5.hexdigest(value)[0,2] Digest::MD5 のクラスメソッド hexdigest は、引数に与えられた値から ハッシュ値 を生成して32桁の16進数として返します。ハッシュ値は固定の長さを持つ擬似乱数で、同一の値からは常に同一のハッシュ値が生成されます。

# * 例えば、「緊急」という文字列の Digest::MD5 によるハッシュ値は、次の通りです。 b48bd4716505181c7206376a126229c4先ほどの式では末尾に [0, 2] とありますので、32桁のハッシュ値の先頭2桁が取られます。つまり、「緊急」という文字列からは "b4" という文字列が得られるわけです。

#  - 以上のことを踏まえて、改めて HashLock.acquireメソッドを見返してください。第1引数に "tags"、第2引数に "value"、第3引数に "緊急" を与えてこのメソッドを呼び出したとすると、次のような式が評価されることになります。

# HashLock.where(table: "tags", column: "value", key: "b4").lock(true).first!

# - この式は、 where メソッドに与えた条件を満たすレコードを hash_locks テーブルのレコードの中から検索して、そのレコードに対して排他的ロックを取得します。これを用いれば、 tags テーブルにおけるレースコンディションを解消できます。
# - 職員がタグを tags テーブルに追加する前に必ず hash_locks テーブル上の該当するレコードに対して排他的ロックを取得するというルールを作ればいいのです。そうすれば、職員Aと職員Bがほぼ同時にXというタグを tags テーブルに追加しようとしている状況でも、先に排他的ロックを取得した職員だけがタグを追加し、もう一人の職員は追加済みのタグを利用することになります。
# - ただし、 Digest::MD5.hexdigest(value)[0,2] という式が返す値の種類はたかだか256種類しかありませんので、別々のタグに対して偶然同じ値を返す可能性があります。しかし、たとえそうなったとしても、一人の職員がほんの一瞬待たされるだけです。

