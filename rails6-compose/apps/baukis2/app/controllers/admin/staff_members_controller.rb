# class Admin::StaffMembersController < ApplicationController
class Admin::StaffMembersController < Admin::Base

  def index

    # ! 20230806 同様の対策を他の6つのアクションに対しても行えば問題は解決します。しかし、まったく同じコードをすべてのアクションに複写するのは面倒ですし、ソースコードの保守作業がやりにくくなります。そこで登場するのがクラスメソッド before_action です。
    # unless current_administrator
    #   # redirect_to admin_login_path
    #   redirect_to :admin_login
    # end

    @staff_members = StaffMember.order(:family_name_kana, :given_name_kana).page(params[:page])
  end

  def show
    staff_member = StaffMember.find(params[:id])
    redirect_to [:edit, :admin, staff_member]
    # ¥ 下記のようにも書ける rails routes で確認できる 20230804
    # redirect_to edit_admin_staff_member_path(id: staff_member.id)
  end

  def new
    @staff_member = StaffMember.new
  end

  # ¥ http://baukis2.example.com:3000/admin/staff_members/6/edit
  # !クリック時の <a href="/admin/staff_members/6/edit">編集</a> の 6が params[:id] に入る!!
  def edit
    @staff_member = StaffMember.find(params[:id])
  end

  def create
    puts("●create_params", params)
    # ¥ f.submitが押されたことで inputに入力した内容がstaff_member　の中にすべて詰め込まれ paramsで取得可能になる!! 20230805
    # {"authenticity_token"=>"rYWqUN0A3pdji2OODQoSxbk5yy+38chPd31okEZcjDrTpy/L5TH+buJ6GqweSkHcC6JOiNTUjDfKeFCYWPNXOQ==", "staff_member"=>{"email"=>"test@gmail.com", "password"=>"test", "family_name"=>"test1", "given_name"=>"42", "family_name_kana"=>"33", "given_name_kana"=>"44", "start_date"=>"2023-08-01", "end_date"=>"", "suspended"=>"0"}, "commit"=>"登録", "host"=>"baukis2.example.com", "controller"=>"admin/staff_members", "action"=>"create"}

    # ¥ Railsでform_with modelを使ってフォームを作成すると、Railsは以下のようになります： staff_memberを使ってRailsでフォームを作成すると、Railsはモデルの名前 (この場合はStaffMemberモデルのインスタンスである@staff_member) を使ってフォームの入力に名前を付けます。モデルの各属性 (メールアドレス、パスワードなど) に対応する入力を作成し、これらの入力をモデル (この場合は staff_member) にちなんだキーの下にネストします。そのため、フォームが送信されると、フォームデータにはstaff_member[email]、staff_member[password]などのキーが含まれます。
    # @staff_member = StaffMember.new(params[:staff_member])
    # ¥ 20230805 マスアサインメント脆弱性対策 Strong Parametersによる防御
    @staff_member = StaffMember.new(staff_member_params)

    if @staff_member.save
      flash.notice = "職員アカウントを新規登録しました。"

      redirect_to :admin_staff_members
    else
      render action: "new"
    end
  end

  def update
    # ¥20230805 #editの画面におり、/admin/staff_members/24/edit のように id が設定されていることから取得できる
    #! Railsで:idのような動的セグメントを持つルートを作成すると(たとえばresources :staff_membersは/staff_members/:idのようなルートを作成します)、Railsは自動的にその動的セグメントの値を取得し、paramsオブジェクトを通してコントローラのアクションで利用できるようにします。
    @staff_member = StaffMember.find(params[:id])

    # ¥ 属性の一括登録 20230805 どちらの書き方も可能
    @staff_member.assign_attributes(staff_member_params)
    # @staff_member.attributes = params[:staff_member]
    if @staff_member.save
      flash.notice="職員アカウントを更新しました。"
      redirect_to :admin_staff_members
    else
      render action: "edit"
    end
  end # end of update

  # ¥ 20230805 マスアサインメント脆弱性対策 Strong Parametersによる防御
  private def staff_member_params
    params.require(:staff_member).permit(:email, :password, :family_name, :given_name,
    :family_name_kana, :given_name_kana, :start_date, :end_date, :suspended)
  end

  def destroy
    staff_member = StaffMember.find(params[:id])
    #! .destroy ではなく、 .destroy! とすることで動作が失敗したときにエラーを発生させる
    # staff_member.destroy!
    # # ¥ コメントアウトおようにも記述可能!
    # # flash[:notice] = 'StaffMember was successfully deleted.'
    # flash.notice = '職員アカウントを削除しました。'
    # ¥ 2.ch6.1.3
    if staff_member.deletable?
      staff_member.destroy!
      flash.notice = '職員アカウントを削除しました。'
    else
      flash.alert = "この職員アカウントは削除できません。"
    end

    # redirect_to admin_staff_members_url
    redirect_to :admin_staff_members
  end


end

# ¥ 20230725 staff_members テーブルのすべてのレコードを取得し、 StaffMember オブジェクトの配列としてインスタンス変数@staff_members にセットしています。ただし正確に言えば、ERBテンプレートの側で@staff_members に対して each メソッドが呼び出されるまでは、データベースに対してクエリは発行されない