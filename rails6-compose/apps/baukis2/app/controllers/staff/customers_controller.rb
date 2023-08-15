# class Staff::CustomersController < ApplicationController
class Staff::CustomersController < Staff::Base
  def index
    @customers = Customer.order(:family_name_kana, :given_name_kana).page(params[:page])
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def new
    @customer_form = Staff::CustomerForm.new
  end

  def edit
    # ¥ .new()の中の引数でどのカスタマーか特定している 20230813
    @customer_form = Staff::CustomerForm.new(Customer.find(params[:id]))
  end

  # - 20230815 この行は、.persisted? と .save メソッドが @customer オブジェクトに委譲されていることを示しています。つまり、Staff::CustomerFormのインスタンスで.saveを呼び出すと、実際にはフォームがラップしている@customerオブジェクトで.saveが呼び出されるということです。
  # - つまり、.save メソッドは @customer オブジェクトから呼び出され、Customer クラスのインスタンスに見えます。Customerクラスが典型的なActive Recordモデル（Railsアプリケーションでは一般的な慣習です）である場合、.saveメソッドはActiveRecord::Baseから継承されます。
  def create
    @customer_form = Staff::CustomerForm.new
    # ¥ 引数に paramsではなく、params[:form] を入れていることに注意! 20230815
    @customer_form.assign_attributes(params[:form])
    # ! customer_form.rb で delegate しない場合、
    # - if @customer_form.customer.save    と書かなければならない 20230815
    if @customer_form.save
      flash.notice = "顧客を追加しました。"
      redirect_to action: "index"
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "new"
    end
  end

  def update
    @customer_form = Staff::CustomerForm.new(Customer.find(params[:id]))
    @customer_form.assign_attributes(params[:form])
    if @customer_form.save
      flash.notice = "顧客情報を更新しました。"
      redirect_to action: "index"
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "edit"
    end
  end

  def destroy
    customer = Customer.find(params[:id])
    customer.destroy!
    flash.notice = "顧客アカウントを削除しました。"
    redirect_to :staff_customers
  end
end
