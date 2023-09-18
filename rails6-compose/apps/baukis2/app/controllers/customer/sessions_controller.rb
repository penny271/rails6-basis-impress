# class Customer::SessionsController < ApplicationController
#- 2.ch4
class Customer::SessionsController < Customer::Base
  skip_before_action :authorize

  def new
    if current_customer
      redirect_to :customer_root
    else
      @form = Customer::LoginForm.new
      render action: "new"
    end
  end

  def create
    @form = Customer::LoginForm.new(login_form_params)
    if @form.email.present?
      customer =
        Customer.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    if Customer::Authenticator.new(customer).authenticate(@form.password)
      # session[:customer_id] = customer.id
      # ¥ 2.ch4.2.2 自動ログイン機能 一番下に解説あり
      if @form.remember_me?
        cookies.permanent.signed[:customer_id] = customer.id
      else
        cookies.delete(:customer_id)
        session[:customer_id] = customer.id
      end

      flash.notice = "ログインしました。"
      redirect_to :customer_root
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
    #   if @form.remember_me?
    #     cookies.permanent.signed[:customer_id] = customer.id
    #   else
    #     cookies.delete(:customer_id)
    #     session[:customer_id] = customer.id
    #   end
    #   flash.notice = "ログインしました。"
    #   redirect_to :customer_root
    # else
    #   flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
    #   render action: "new"
    # end
  end

  private def login_form_params
    params.require(:customer_login_form).permit(:email, :password, :remember_me)
  end

  def destroy
    # ¥ 2.ch4.2.2
    cookies.delete(:customer_id)
    session.delete(:customer_id)
    flash.notice = "ログアウトしました。"
    redirect_to :customer_root
  end
end

# ¥ 2.ch4.2.2 アクションの中でクッキーに値をセットする場合、普通は次のように書きます。 cookies[:customer_id] = customer.id しかし、このようにセットされたクッキーの値は、ブラウザ側で閲覧可能かつ変更可能です。つまり、 customer/sessions コントローラのソースコード21行目をこのように書き換えた場合、クッキーの書き換え方を知っている人であれば誰でも、任意の顧客になりすましてBaukis2の顧客向けページにログインできることになります。 クッキーの値を閲覧不可かつ変更不可にするには、次のように書きます。 cookies.signed[:customer_id] = customer.id こうすれば、顧客なりすましの問題は解決されます。 ただし、デフォルトではクッキーの情報はブラウザ終了時に消滅してしまいます。永続的に情報を残したい場合は、次のように書いてください。 cookies.permanent.signed[:customer_id] = customer.id 。permanentメソッドを用いるとクッキーの有効期限は、20年後に設定される