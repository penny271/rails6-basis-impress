# class Admin::StaffMembersController < ApplicationController
class Admin::StaffMembersController < Admin::Base
  def index
    @staff_members = StaffMember.order(:family_name_kana, :given_name_kana)
  end

  def show
    staff_member = StaffMember.find(params[:id])
    redirect_to [:edit, :admin, staff_member]
    # ¥ 下記のようにも書ける rails routes で確認できる 20230804
    # redirect_to edit_admin_staff_member_path
  end
end

# ¥ 20230725 staff_members テーブルのすべてのレコードを取得し、 StaffMember オブジェクトの配列としてインスタンス変数@staff_members にセットしています。ただし正確に言えば、ERBテンプレートの側で@staff_members に対して each メソッドが呼び出されるまでは、データベースに対してクエリは発行されない