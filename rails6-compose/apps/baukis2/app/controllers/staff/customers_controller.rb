# class Staff::CustomersController < ApplicationController
class Staff::CustomersController < Staff::Base
  def index
    # @search_form = Staff::CustomerSearchForm.new #- 2.ch3 20230819
    @search_form = Staff::CustomerSearchForm.new(search_params)
    # @customers = Customer.order(:family_name_kana, :given_name_kana).page(params[:page])
    # - 2.ch3 @search_form.search で customer_search_form.rb の searchメソッドを使用し、フィルタリングしている
    @customers = @search_form.search.page(params[:page])
  end

  # ¥ マスアサインメント対策 ストロングパラメータ
  private def search_params
    #! NG params.require(:search).permit(:)
    # - しかし、上記のように書くと、ダッシュボードから顧客管理ページに遷移したときに、例外 ActionController::ParameterMissing が発生します。パラメータに"search" が含まれないからです。そこで、 params のキーに"search" が含まれるかどうかのチェックをスキップしています。 ダッシュボードから顧客管理ページに遷移した場合は、 params[:search] は nil を返します。その nil に対して&. 演算子を適用すると nil が返ります。検索フォームから index アクションが呼ばれた場合は、 params[:search] は ActionController::Parameters オブジェクトを返します。このオブジェクトに対して &. 演算子を適用すると、 permit メソッドが呼び出されます。
    #¥ _search_form.html.erbにて scope: "search" としていることから paramsの引数は :searchとなっている
    params[:search]&.permit([:family_name_kana, :given_name_kana, :birth_year, :birth_month, :birth_mday, :address_type, :prefecture, :city, :phone_number, :gender, :postal_code, :last_four_digits_of_phone_number
    ])
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
