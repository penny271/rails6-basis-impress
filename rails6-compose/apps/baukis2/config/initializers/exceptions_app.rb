Rails.application.configure do
  config.exceptions_app = ->(env) do
    request = ActionDispatch::Request.new(env)

    action =
      case request.path_info
      when "/404"; :not_found
      when "/422"; :unprocessable_entity
      else; :internal_server_error
      end

    Rails.logger.warn("/config/initializers/exceptions_app.rb -- env:::#{env}")
    Rails.logger.warn("/config/initializers/exceptions_app.rb -- request.path_info:::#{request.path_info}")
    Rails.logger.warn("/config/initializers/exceptions_app.rb -- action:::#{action}")

    ErrorsController.action(action).call(env)
  end
end

# ¥ 変数 envは勝手に代入される 20230723
# そう、このラムダ関数のコンテキストでは、envはアプリケーションが現在処理しているリクエストの環境を表します。この環境は、エラーが発生するたびにRailsからラムダ関数に自動的に渡されます。

# ¥ envオブジェクトには、リクエストされたURL、使用されたHTTPメソッド、リクエストと一緒に送信されたヘッダーやクッキーなど、現在のリクエストに関する多くの情報が含まれています。言い換えると、エラーが発生した時点でのリクエストの状態をカプセル化しています。

# そのため、アプリケーションでエラーが発生すると、Railsは自動的にconfig.exceptions_appラムダ関数を呼び出し、現在のリクエスト環境をenvとして渡します。

# そして、ラムダ関数の中でこのenvオブジェクトにアクセスし、それを使ってエラーの処理方法を決めることができます。提供されたコードスニペットの場合、envオブジェクトはActionDispatch::Requestオブジェクトの生成に使用され、エラーに対してどのアクションを実行するかを決定するために使用されます。