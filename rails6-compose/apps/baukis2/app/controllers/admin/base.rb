class Admin::Base < ApplicationController
  # ¥ 2.ch5.問題 ipアドレスによるアクセス制限
  before_action :check_source_ip_address
  # ¥ 20230806 before_actionの継承
  before_action :authorize
  before_action :check_account
  before_action :check_timeout

  private def current_administrator
    if session[:administrator_id]
      @current_administrator ||=
        Administrator.find_by(id: session[:administrator_id])
    end
  end

  helper_method :current_administrator

  private def check_source_ip_address
    #  - クラスメソッド呼出 AllowedSource.include?("admin", request.ip)
    raise IpAddressRejected unless AllowedSource.include?("admin", request.ip)
  end

  private def authorize
    unless current_administrator
      # redirect_to admin_login_path
      flash.alert = "管理者としてログインしてください。"
      redirect_to :admin_login
    end
  end

  private def check_account
    if current_administrator && current_administrator.suspended?
      session.delete(:administrator_id)
      flash.alert = "アカウントが無効になりました。"
      redirect_to :admin_root
    end
  end

  TIMEOUT = 60.minutes
  # TIMEOUT = 5.seconds

  private def check_timeout
    if current_administrator
      if session[:admin_last_access_time] >= TIMEOUT.ago
        session[:admin_last_access_time] = Time.current
      else
        session.delete(:administrator_id)
        flash.alert = "セッションがタイムアウトしました。 email: hanako@example.com / pass: foobar でログイン可能"
        redirect_to :admin_login
      end
    end
  end

end


# ¥ 20230806 ログインしているかどうかを事前にチェックし、遷移先を決定する
#^  before_action は、そのコントローラの各アクションが呼び出される直前に実行されるべきメソッドを登録するクラスメソッドです。  before_action :メソッド名  と記述する
#! 親クラスに before_action :authorize を記述することで staff_members_controller.rb 等にも継承され、そのコントローラーを通る前にbefore_action :authorize が実行される