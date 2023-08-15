# class Staff::TopController < ApplicationController
class Staff::TopController < Staff::Base
  # ! 20230806 ここで skip_before_action しないと、ログインしていないユーザーはtopページにたどり着けないため設定している
  skip_before_action :authorize

  def index
    if current_staff_member
      render action: "dashboard"
    else
      # raise # エラー確認用
      render action: "index"
    end
  end
end


#¥ これらの変更を行った結果、 Staff::TopController の継承関係が次のように変わります。
# 変更前 …… Staff::TopController ← ApplicationController
# 変更後 …… Staff::TopController ← Staff::Base ← ApplicationController
