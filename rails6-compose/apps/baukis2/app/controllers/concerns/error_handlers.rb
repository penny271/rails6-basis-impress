module ErrorHandlers
  extend ActiveSupport::Concern

  # code here will be executed as if it were in the class including this module
  included do
    # ¥ rescue_from: 特定のメソッドで特定のタイプの例外をレスキューするようRailsに指示するメソッドです。20230723
    #! エラーが発生すると、Railsはまずそのエラーが最後に記載されている順、この場合だと、IpAddressRejected、次にForbidden、最後にStandardErrorのインスタンスかどうかをチェックします。この動作は、特に同じクラス階層に属する例外を処理するときに重要です。例えば、StandardErrorはRubyの他の多くのエラークラスのスーパークラスである。そのため、もしrescue_from StandardError節がコードの最後に書かれていたら、すべての標準エラーを捕捉してしまい、後の節に到達することはありません。したがって、一般的には、より一般的なエラーの前に、より具体的なエラーを列挙すべきです。
    rescue_from StandardError, with: :rescue500
    rescue_from ApplicationController::Forbidden, with: :rescue403
    # rescue_from ApplicationController::IpAddressRejected, with: :rescue403
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404
    # ¥ 2.ch.10.2.5 問い合わせ到着の通知 ajax
    rescue_from ActionController::BadRequest, with: :rescue400
    rescue_from ActionController::ParameterMissing, with: :rescue400
  end

  private def rescue400(e)
    render "errors/bad_request", status: 400
  end

  # private def rescue403(e)
  #   @exception = e
  #   render "errors/forbidden", status: 403
  # end

  private def rescue404(e)
    render "errors/not_found", status: 404
  end

  private def rescue500(e)
    render "errors/internal_server_error", status: 500
  end
end

# ! extend ActiveSupport::Concern が必要な理由:
# ActiveSupport::Concernを使用すると、定義したモジュールにインクルードブロックを含めることができます。このブロックは、モジュールをインクルードしたクラスのコンテキストで実行され、あたかもクラス自体に直接コードを書いたかのようになります。

#- includedブロックでは、クラスレベルのメソッドであるrescue_fromメソッドを呼び出しています。このメソッドは、標準的な方法でモジュールをインクルードした場合（ActiveSupport::Concernを使わない場合）にはアクセスできません。デフォルトでは、モジュールがクラスにインクルードされると、モジュールで定義されたメソッドはインスタンスメソッドになるからです。

# つまり、あなたの例では、インクルードされたブロックを使い、その中でクラスレベルのメソッドを呼び出しているので、extend ActiveSupport::Concern の行が必要なのです。

# ¥ app/controllers/concerns は、 ActiveSupport::Concern という仕組みのためのディレクトリです。このディレクトリにはコントローラで使用するモジュールを配置します。concerns ディレクトリに置くモジュールには必ずこの記述を加えます。するとこのモジュールに、通常のモジュールにはない2つの性質が加えられます。

#  1つは、 included メソッドが利用可能になります。このメソッドはブロックを取り、ブロック内のコードがモジュールを読み込んだクラスの文脈で評価されます。4つの rescue_from メソッドは、 ErrorHandlers モジュールを読み込んだクラス（つまり、 ApplicationController）のクラスメソッドとして評価されることになります。

#! なお、Forbidden クラスと IpAddressRejected クラスに名前空間 ApplicationController が加えられている点に注意してください。抽出元のコードは ApplicationController クラスの中にあったため名前空間の指定が不要でしたが、外に出たため名前空間付きで参照しなければなりません。

# もう1つの性質は、このモジュールのサブクラスとして ClassMethods というクラスを定義しておくと、そのメソッドがモジュールを読み込んだクラスのクラスメソッドとして取り込まれる、というものですが、今回はこの性質を利用しません。 もちろん、モジュールとしての本来の性質も失ってはいません。11～21行に記述されている3つの private メソッドは、 ApplicationController のインスタンスメソッドになります。

