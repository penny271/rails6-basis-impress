# class Staff::TopController < ApplicationController
class Staff::TopController < Staff::Base
  def index
    # raise # エラー確認用
    render action: "index"
  end
end


#¥ これらの変更を行った結果、 Staff::TopController の継承関係が次のように変わります。
# 変更前 …… Staff::TopController ← ApplicationController
# 変更後 …… Staff::TopController ← Staff::Base ← ApplicationController
