class Admin::TopController < Admin::Base
  # ! 20230806 ここで skip_before_action しないと、ログインしていないユーザーはtopページにたどり着けないため設定している
  skip_before_action :authorize #^ :authorize メソッドは base.rb から継承してきている

  def index
    # raise IpAddressRejected
    # render action: "index"
    if current_administrator
      render action: "dashboard"
    else
      render action: "index"
    end
  end
end