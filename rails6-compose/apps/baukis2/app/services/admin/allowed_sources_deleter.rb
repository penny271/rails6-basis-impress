# ¥ 2.ch5.2.7 許可IPアドレスの一括削除
class Admin::AllowedSourcesDeleter
  def delete(params)
    #  - もし、params[:allowed_sources]がnilであったり、値に反応しない他のタイプのオブジェクトであった場合、params[:allowed_sources].values.eachはエラーになります。params[:allowed_sources]の型をチェックすることで、この問題を避けることができます。
    if params && params[:allowed_sources].kind_of?(ActionController::Parameters)
      ids = []

      params[:allowed_sources].values.each do |hash|
        if hash[:_destroy] == "1"
          ids << hash[:id]
        end
      end

      if ids.present?
        AllowedSource.where(namespace: "staff", id: ids).delete_all
      end
    end
  end
end

# ¥ 2.ch5.2.7 許可IPアドレスの一括削除 説明
# 許可IPアドレスの一括削除フォームからは、次のような構造のパラメータが送られてきます。
# { allowed_sources: { "0" => { id: "1", _destroy: "0" }, "1" => { id: "2", _destroy: "1" }, "2" => { id: "3", _destroy: "1" }, "3" => { id: "4", _destroy: "0" } } }

# この場合に、idが2と3の AllowedSource オブジェクトを削除するのが、この delete メソッドの目的です。

# - allowed_sources パラメータの値がハッシュである場合、 values メソッドは次のような配列を返します。
# [ { id: "1", _destroy: "0" }, { id: "2", _destroy: "1" }, { id: "3", _destroy: "1" }, { id: "4", _destroy: "0" } ]

# 上記を下記のように処理する
# ids = []
# params[:allowed_sources].values.each do |hash|
#   if hash[:_destroy] == "1"
#     ids << hash[:id]
#   end
# end

# each メソッドで配列の要素（ハッシュ）を１個ずつ取り出し、そのハッシュの :destroy キーの値が "1" である場合は、:id キーの値を配列 ids に加えています。ループが終了した時点では、配列 ids に削除すべき AllowedSource オブジェクトの主キーがたまります。 これを用いて allowed_sources テーブルから該当するレコードを一括削除します（13行目）。

# AllowedSource.where(namespace: "staff", id: ids).delete_all

