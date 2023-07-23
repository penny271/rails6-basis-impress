class Customer::TopController < ApplicationController
  def index
    # raise Forbidden
    # raise ActiveRecord::RecordNotFound
    render action: "index"
  end
end

# ! 例外ApplicationController::IpAddressRejectedは、コントローラの中では名前空間を省いたIpAddressRejectedで参照できます。なぜなら、ApplicationControllerはすべてのコントローラの親または先祖だからです。Ruby インタープリタは未知の定数IpAddressRejectedに出会うと、まず現在の文脈（Admin::TopController）でその定数が定義されていないかどうかを調べ、定義されていなければその先祖クラスに遡って定数定義を調べていきます