# class Staff::SessionsController < ApplicationController
# ¥ current_staff_memberメソッドを使用するため継承元を変更 20230723
class Staff::SessionsController < Staff::Base
  skip_before_action :authorize

  def new
    if current_staff_member
      redirect_to :staff_root
    else
      @form = Staff::LoginForm.new
      render action: "new"
    end
  end # end of def new


  def create
    # @form = Staff::LoginForm.new(params[:staff_login_form])
    @form = Staff::LoginForm.new(login_form_params)
    puts("params[:staff_login_form]::#{params[:staff_login_form]}")
    # puts("-------------staff_member::#{staff_member}")
    if @form.email.present?
      staff_member =
        StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)
    end
    if Staff::Authenticator.new(staff_member).authenticate(@form.password)
      if staff_member.suspended?
        # ¥ 20230806 ログイン拒否の記録 DBに保存
        staff_member.events.create!(type: "logged_rejected")
        #  - 下記のようにも記述可能
        # StaffEvent.create!(member: staff_member, type: "rejected")
        flash.now.alert = "アカウントが停止されています。"
        render action: "new"
      else
        session[:staff_member_id] = staff_member.id
        # ¥ 20230806 セッションタイムアウト機能用
        session[:last_access_time] = Time.current
        # ¥ 20230806 ログインの記録 DBに保存
        staff_member.events.create!(type: "logged_in")
        flash.notice = "ログインしました。"
        redirect_to :staff_root
      end
    else
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render action: "new"
    end
  end

  # ¥ 20230805 マスアサインメント脆弱性対策
  # ¥ クライアントの送信したデータから不必要なパラメータを除去する処理
  private def login_form_params
    params.require(:staff_login_form).permit(:email, :password)
  end

  # ¥ session.delete(:staff_member_id)でセッションオブジェクトから:staff_member_id というキーを削除することにより、ログイン状態を解除しています。ログアウト後は、職員トップページにリダイレクトされます
  def destroy
    if current_staff_member
      current_staff_member.events.create!(type: "logged_out")
    end
    session.delete(:staff_member_id)
    flash.notice = "ログアウトしました。"
    redirect_to :staff_root
  end


end #! end of class Staff::SessionsController < Staff::Base

# ^ flashの使い方 20230723
# flash はフラッシュオブジェクトを返すメソッドです。フラッシュオブジェクトには alert と notice という2つの属性が用意されていて、通常 alert 属性には警告メッセージ、 notice 属性には普通のメッセージをセットします。18行目でフラッシュオブジェクトに「ログインしました。」というメッセージがセットされて、19行目でリダイレクションが行われます。リダイレクション先のアクション（ staff/top コントローラの index アクション）では、フラッシュオブジェクトを参照してこのメッセージを画面に表示します。28～29行でも同様のことが行われています

# flash.alert = "..."と書く代わりに flash.now.alert = "..."と書くと、 alert 属性にセットされた値がこのアクションの終了時に消えるようになります。フラッシュオブジェクトにセットしたメッセージを、このアクションでしか使用しない場合は、このように書いてください

# ¥ @form = Staff::LoginForm.new(params[:staff_login_form]) は
# ¥ {email: "abc@example.com", password:"foobar"} のような構造のハッシュを返す

# renderとredirect_toはどちらもRailsコントローラのメソッドですが、役割は異なります：

# render： render:このメソッドはテンプレートからレスポンスを生成するために使われます。renderを呼び出すと、Railsは渡した引数 (引数を渡さなかった場合はアクション名) に一致するビューテンプレートを探し、そのテンプレートを使ってユーザーのブラウザに送信するレスポンスを生成します。このメソッドは新しいリクエストを開始しません。

# 例: render :new は、現在のコントローラに対応する 'new' テンプレートをレンダリングします。

# redirect_to： このメソッドはユーザーのブラウザに HTTP 302 リダイレクトを送信し、指定した URL に新しい HTTP リクエストを送信するように指示します。これはルートヘルパーメソッド、文字列、コントローラ/アクション/idを記述したハッシュなどです。言い換えると、ブラウザに別の場所に行くように指示します。

# 例: redirect_to root_pathは、ユーザーのブラウザをroot_pathメソッドが返すパス（おそらくアプリケーションのルートURL）にリダイレクトします。

#¥ まとめると、renderは新しいリクエストを開始することなく単にビューを表示しますが、redirect_toはブラウザに新しいHTTPリクエストを別の場所に送信させます。