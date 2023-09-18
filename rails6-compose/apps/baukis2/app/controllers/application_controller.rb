class ApplicationController < ActionController::Base
  layout :set_layout

  #¥ ActionController::ActionControllerErrorを継承することで例外クラスを作成している 20230723
  #! また、これらのクラスは ApplicationController クラスの中で定義されています。この場合、 ApplicationController がモジュールとしての役割を果たし、それらの名前空間となります。すなわち、 ApplicationController の文脈以外で参照するときは、 ApplicationController::Forbidden や ApplicationController::IpAddressRejected のように書かなければなりません。
  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  # ¥ 本番環境のみErrorHandlersを起動する - 開発だと既存のエラーメッセージのほうがデバッグしやすいため20230723
  #^ rails6-compose/apps/baukis2/app/controllers/concerns/error_handlers.rb の中に module ErrorHandler がある 20230805
  # include ErrorHandlers
  include ErrorHandlers if Rails.env.production?
  # ¥ 2.ch5.1.2 ipアドレスによるアクセス制限
  rescue_from ApplicationController::Forbidden, with: :rescue403
  rescue_from ApplicationController::IpAddressRejected, with: :rescue403

  private def set_layout
    if params[:controller].match(%r{\A(staff|admin|customer)/})
      selected_layout = Regexp.last_match[1]
    else
      selected_layout = "customer"
    end
    puts("params[:controller]:::#{params[:controller]}")
    return selected_layout
  end # private def set_layout

  private def rescue403(e)
    @exception = e
    render "errors/forbidden", status: 403
  end

end # end of class ApplicationController < ActionController::Base

# 変更の目的は、レイアウトを決定する仕組みのカスタマイズです。通常は、コントローラ名と同じ名前のレイアウトが優先的に選択され、それが存在しなければ application という名前のレイアウトが選択されます。たとえば、 staff/top コントローラのアクションでERBテンプレートからHTML文書を生成する場合、まず app/views/layouts/staff/top.html.erb が第1候補で、 app/views/layouts/application.html.erb が第2候補となります。しかし、ここではまったく別の論理でレイアウトを決定しています。 2行目では layout メソッドでレイアウトを決定するためのメソッドを指定しています。 5行目の params は paramsオブジェクト を返すメソッドです。 params オブジェクトに関してはChapter 8で詳しく説明しますが、 params[:controller] で現在選択されているコントローラの名前を取得できます。コントローラの名前は"staff/top" のような形をしています。 String クラスのインスタンスメソッド match は引数に正規表現を取り、レシーバ（すなわちURLパス）がその正規表現と合致するかどうかを調べます。%r{ から}までが正規表現です。\A は文字列の先頭にマッチします。次の(staff|admin|customer) は"staff" または"admin" または"customer" にマッチします。最後の/ はスラッシュ記号（/）そのものにマッチします。 Regexp.last_match は正規表現にマッチした文字列に関する情報を保持する MatchData オブジェクトを返します。 Regexp.last_match[1] は正規表現に含まれる1番目の括弧で囲まれた部分にマッチした文字列を返します。つまり、 set_layout メソッドは全体として"staff" または"admin" または"customer" という文字列を返すことになります。この文字列がレイアウトの名前として使われることになるわけです。