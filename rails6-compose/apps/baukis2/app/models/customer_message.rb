class CustomerMessage < Message
  # ¥ 2.ch.10.2.2 問い合わせ到着の通知 ajax
  # スコープとは検索条件の組み合わせに名前を付けた物です。 scope メソッドの第2引数は Proc オブジェクトで、その中に where、 order、 includes などの検索条件を指定するメソッドを記述します。
  scope :unprocessed, -> { where(status: "new", deleted: false) }
end