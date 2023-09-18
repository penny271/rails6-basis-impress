class Staff::Base < ApplicationController
  # ¥ 2.ch5.1.4 ipアドレスによるアクセス制限
  before_action :check_source_ip_address
  before_action :authorize
  before_action :check_account
  before_action :check_timeout # 20230806

  private def current_staff_member
    # - sessions_controller.rbで取得: session[:staff_member_id] = staff_member.id
    if session[:staff_member_id]
      #¥ Rubyの||=演算子は、しばしば「or equals」演算子と呼ばれる。これは、ある変数が現在nilかfalseである場合にのみ、その変数をある値に設定するために使われます。 20230723
      @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id])
    end
  end

  helper_method :current_staff_member

  private def check_source_ip_address
    raise IpAddressRejected unless AllowedSource.include?("staff", request.ip)
  end

  private def authorize
    unless current_staff_member
      flash.alert = "職員としてログインしてください。"
      redirect_to :staff_login
    end
  end

  # ¥ 20230806 強制ログアウト機能
  private def check_account
    # ¥ baukis2/app/models/staff_member.rb のモデル内で設定した .active? メソッドを使うことができる!
    # ^ @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id]) は StaffMemberクラスを継承しているため 20230806
    if current_staff_member && !current_staff_member.active?
      session.delete(:staff_member_id)
      flash.alert = "アカウントが無効になりました。"
      redirect_to :staff_root
    end
  end

  # ¥ 20230806 セッションタイムアウト処理
  # 整数60に対して minutes メソッドを呼び出すと、「3600秒」に相当する ActiveSupport::Duration オブジェクトが返ってくる
  TIMEOUT = 60.minutes
  # TIMEOUT = 5.seconds #検証用

  private def check_timeout
    if current_staff_member
      # ! app/controllers/staff/sessions_controller.rb で session[:last_access_time] = Time.current として定義しているため使用可能
      if session[:last_access_time] >= TIMEOUT.ago # 現在時刻から TIMEOUT分(3600秒)遡った時間を取得
        session[:last_access_time] = Time.current # 最終アクセス時刻を更新
      else
        session.delete(:staff_member_id)
        flash.alert = "セッションがタイムアウトしました。 email: taro@example.com / pass: password でログイン可能"
        redirect_to :staff_login
      end
    end
  end

end

#¥ 7.3.2　 current_staff_memberメソッドの定義 名前空間 staff に属するすべてのコントローラに current_staff_member という private メソッドを与えるため、 Staff::Base というクラスを定義します。 app/controllers/staff ディレクトリに新規ファイル base.rb を次のような内容で作成してください。

#¥ base.rb の9行目にある helper_method は引数に指定したシンボルと同名のメソッドをヘルパーメソッドとして登録するメソッドです。つまり、 current_staff_member というメソッドを app/helpers/application_helper.rb に定義するのと同じ効果が得られます。この結果、 current_staff_member メソッドをERBテンプレートの中でも利用することが可能となります。

# これらの変更を行った結果、 Staff::TopController の継承関係が次のように変わります。
# 変更前 …… Staff::TopController ← ApplicationController
# 変更後 …… Staff::TopController ← Staff::Base ← ApplicationController

#! 遅延初期化
# current_staff_member は、現在ログインしている StaffMember オブジェクトを返すメソッドです。このメソッドでは 遅延初期化 というテクニックを用いています。 current_staff_member メソッドが初めて呼ばれたとき、インスタンス変数@current_staff_member の中身は nil であるため、演算子 ||= の右辺が評価されて@current_staff_member にセットされます。そして、このメソッドが2回目以降に呼び出されたときは、@current_staff_member に nil でも false でもない値がセットされているので、演算子 ||= の右辺は評価されずに、そのまま@current_staff_member の値が返されます。

# このようにすることで、 StaffMember.find_by メソッドが多くても1回しか呼ばれないようにしています。これを遅延初期化と呼びます。 3行目で使われている session は セッションオブジェクト を返すメソッドです。セッションオブジェクトはRailsアプリケーションがクライアントごとに保持するデータで、普通のハッシュ同様に読み書きできます。このオブジェクトに:staff_member_id というキーがあれば、その値を用いて StaffMember を検索して@current_staff_member にセットします。