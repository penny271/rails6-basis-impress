# class Staff::PasswordController < ApplicationController
class Staff::PasswordsController < Staff::Base
  def show
    # ¥ 単数リソースなので :id なし
    redirect_to :edit_staff_password
  end

  def edit
    # ¥ object属性に職員本人のStaffMemberオブジェクトを指定してフォームオブジェクトを生成している 20230809
    # - app/forms/staff/change_password_form.rb という型を通じて@change_password_form objectにcurrent_staff_memberを入れた上で@change_password_formを作成している
    @change_password_form = Staff::ChangePasswordForm.new(object: current_staff_member)
  end

  def update
    @change_password_form = Staff::ChangePasswordForm.new(staff_member_params)
    @change_password_form.object = current_staff_member
    if @change_password_form.save
      flash.notice = "パスワードを変更しました。"
      redirect_to :staff_account
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "edit"
    end
  end

  # ¥ ストロングパラメータ マスアサインメント対策
  private def staff_member_params
    params.require(:staff_change_password_form).permit(
      :current_password, :new_password, :new_password_confirmation
    )
  end
end
