# class Customer::TopController < ApplicationController
class Customer::TopController < Customer::Base
  skip_before_action :authorize

  def index
    # raise Forbidden
    # raise ActiveRecord::RecordNotFound
    # render action: "index"
    # ¥ 2.ch.8.1.2 プログラム一覧表示・詳細表示機能(顧客向け)
    if current_customer
      render action: "dashboard"
    else
      render action: "index"
    end
  end
end

# ! 例外ApplicationController::IpAddressRejectedは、コントローラの中では名前空間を省いたIpAddressRejectedで参照できます。なぜなら、ApplicationControllerはすべてのコントローラの親または先祖だからです。Ruby インタープリタは未知の定数IpAddressRejectedに出会うと、まず現在の文脈（Admin::TopController）でその定数が定義されていないかどうかを調べ、定義されていなければその先祖クラスに遡って定数定義を調べていきます