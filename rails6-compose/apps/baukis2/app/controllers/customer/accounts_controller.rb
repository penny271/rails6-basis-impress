# ¥ 2.ch.9.1.2 顧客自身によるアカウント管理機能
# class Customer::AccountsController < ApplicationController
class Customer::AccountsController < Customer::Base
  def show
    @customer = current_customer
  end

  def edit
    @customer_form = Customer::AccountForm.new(current_customer)
  end

  # ¥ 2.ch.9.2.4 顧客自身によるアカウント管理機能
  # PATCH
  # * confirm アクションではフォームオブジェクトをデータベースに保存する代わりに、バリデーションだけを行い、バリデーションに成功すれば確認画面を表示するのです
  def confirm
    @customer_form = Customer::AccountForm.new(current_customer)
    @customer_form.assign_attributes(params[:form])
    if @customer_form.valid?
      render action: "confirm"
    else
      flash.now.alert = "⼊⼒に誤りがあります。"
      render action: "edit"
    end
  end

  # ¥ 2.ch.9.1.4 顧客自身によるアカウント管理機能
  def update
    @customer_form = Customer::AccountForm.new(current_customer)
    @customer_form.assign_attributes(params[:form])
    # if @customer_form.save
    #   flash.notice = "アカウント情報を更新しました。"
    #   redirect_to :customer_account
    # else
    #   flash.now.alert = "⼊⼒に誤りがあります。"
    #   render action: "edit"
    # end
    # ¥ 2.ch.9.3.8 訂正ボタン
    # * confirm.html.erbより フォームビルダーの submit メソッドには name オプションを与えることができます。これは input 要素の name 属性の値として用いられます。 name オプションのデフォルト値が "commit" です。フォームが送信されると、クリックされたボタンの name 属性をキーとするパラメータも同時に送信されます。つまり、「更新」ボタンがクリックされると "commit" というキーのパラメータが、「訂正」ボタンがクリックされると、"correct" というキーのパラメータが update アクションに渡ります。 したがって、 params[:commit] に値がセットされているかどうかで、どちらのボタンが押されたのかが判定できるというわけです
    if params[:commit]
      if @customer_form.save
        flash.notice = "アカウント情報を更新しました。"
        redirect_to :customer_account
      else
        flash.now.alert = "⼊⼒に誤りがあります。"
        render action: "edit"
      end
    else
      render action: "edit"
    end
  end
end