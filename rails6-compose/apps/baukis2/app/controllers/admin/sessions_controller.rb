class Admin::SessionsController < Admin::Base
  #¥ 下記のエラーが起きないようにするため、設定する 無限リダイレクトループが起きている
  #! このページは動作していませんbaukis2.example.com でリダイレクトが繰り返し行われました。
  #! ERR_TOO_MANY_REDIRECTS
  skip_before_action :authorize #^ :authorize メソッドは base.rb から継承してきている

  def new
    if current_administrator
      redirect_to :admin_root
    else
      #¥ 20230805 rails6-basis-impress/rails6-compose/apps/baukis2/app/forms/admin/login_form.rb があるため、@formインスタンスを作成可能!
      @form = Admin::LoginForm.new
      render action: "new"
    end
  end

  def create
    # ¥ formのinputタグのnameのプレフィクス admin_login_form paramsとして渡すことでこの2つの属性をフォームに付与できる 20230802
    # <input type="text" name="admin_login_form[email]" id="admin_login_form_email">
    # <input type="password" name="admin_login_form[password]" id="admin_login_form_password">

    # ¥ 20230805 マスアサインメント脆弱性対策 Strong Parametersによる防御
    # @form = Admin::LoginForm.new(params[:admin_login_form])
    @form = Admin::LoginForm.new(login_form_params)
    if @form.email.present?
      administrator =
        Administrator.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    if Admin::Authenticator.new(administrator).authenticate(@form.password)
      if administrator.suspended?
        flash.now.alert = "アカウントが停止されています。"
        render action: "new"
      else
        session[:administrator_id] = administrator.id
        session[:admin_last_access_time] = Time.current
        flash.notice = "ログインしました。"
        redirect_to :admin_root
      end
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
  end # end of create

  # ¥ 20230805 マスアサインメント脆弱性対策 Strong Parametersによる防御
  # ¥ クライアントの送信したデータから不必要なパラメータを除去する処理
  private def login_form_params
    params.require(:admin_login_form).permit(:email, :password)
    # ^ 戻り値の例(permitで許可されたもののみ取得する): {email: "xxx@example.com", password: "test"}
  end

  def destroy
    session.delete(:administrator_id)
    flash.notice = "ログアウトしました。"
    redirect_to :admin_root
  end
end

# ¥ マスアサインメント対策の仕組み: 20230805
# ^ params は params オブジェクトを返すメソッドです。まず paramsオブジェクトの require メソッドを呼び出すことによって、 params オブジェクトが:admin_login_form というキーを持っているかどうかを調べています。もし持っていなければ例外 ActionController::ParameterMissing が発生します。

# require メソッドの戻り値は ActionController::Parameters クラス（ Hash の子孫クラス）のインスタンスです。 require メソッドは指定されたキーに対応する値を返します。

# たとえば、 params オブジェクトが次のハッシュに相当する構造を持っているとします。 { admin_login_form: { email: "test@example.com", password: "foobar" } } このとき、 params.require(:admin_login_form) は、次のハッシュに相当する構造を持つ ActionController::Parameters オブジェクトを返します。
#  { email: "test@example.com", password: "foobar" } このオブジェクトに対して permit メソッドを呼び出すと、引数に指定されていないパラメータが除去されます。

#  したがって、 params.require(:admin_login_form).permit(:email) は次のハッシュに相当する構造を持つ ActionController::Parameters オブジェクトを返します。 { email: "test@example.com" }

#  以上のような仕組みにより、 login_form_params メソッドは、クライアントの送信したデータから不必要なパラメータを除去します。



