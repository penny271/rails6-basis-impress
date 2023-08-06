# class Staff::AccountsController < ApplicationController
class Staff::AccountsController < Staff::Base
  def show
    @staff_member = current_staff_member
  end

  def edit
    @staff_member = current_staff_member
  end

  def update
    @staff_member = current_staff_member
    # if @staff_member.update_attributes(params[:staff_@staff_member])
    #   flash[:success] = "StaffMember was successfully updated"
    #   redirect_to @staff_member
    # else
    #   flash[:error] = "Something went wrong"
    #   render 'edit'
    # end

    # @staff_member.assign_attributes(params[:staff_member])
    @staff_member.assign_attributes(staff_member_params)
    if @staff_member.save
      flash.note = "アカウント情報を更新しました。"
      redirect_to :staff_account
    else
      render action: "edit"
    end
  end

  # ¥ 20230805 マスアサインメント脆弱性対策 Strong Parametersによる防御
  private def staff_member_params
    params.require(:staff_member).permit(:email, :family_name, :given_name, :family_name_kana, :given_name_kana)
  end

  # ! 20230805 private メソッド staff_member_params についても、 admin/staff_members コントローラの同名メソッドとほぼ同じですが、 permit メソッドに指定されている属性のリストが異なります。管理者が職員アカウントを更新する際には、開始日（ start_date）、終了日（ end_date）、停止フラグ（ suspended）も変更可能でしたが、これらの属性については職員自身によって変えられないようにしてあります。

  # !また、パスワード（ password）もリストから除いてあります。パスワードの変更機能はChapter 15で作成します。 この章の前半で書いたことの繰り返しになりますが、たとえブラウザ上のフォームに変更可能な属性のためのフィールドしか表示されていないとしても、Strong Parametersによる防御機構がなければ、職員が簡単なスクリプトを書いて自分自身の終了日や停止フラグを変更できることになります。それは重大なセキュリティホールとなる可能性があります


end
