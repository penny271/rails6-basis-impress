#- 1.ch14
# class Staff::PasswordController < ApplicationController
class Staff::PasswordsController < Staff::Base
  def show
    # ¥ 単数リソースなので :id なし
    redirect_to :edit_staff_password
  end

  # ^ editアクションでは、通常、ユーザーにフォームを表示します。フォームオブジェクト(ここでは@change_password_form)を初期化する主な目的は、フォームのフィールドを設定することです。
  def edit
    # ¥ object属性に職員本人のStaffMemberオブジェクトを指定してフォームオブジェクトを生成している 20230809
    # - app/forms/staff/change_password_form.rb という型を通じて@change_password_form objectにcurrent_staff_memberを入れた上で@change_password_formを作成している
    #! 20230811 .new(object: current_staff_member) としている理由は、change_password_form.rb valiated do の中で unless Staff::Authenticator.new(object).authenticate(current_password) と objectを使った validationを行っているため object: current_staff_member と引数で渡す必要がある!!
    #- editの場合 .new() でも問題なく、変更することができた - editの段階では、objectを使った バリデーションを行わないため。 update時に入力された値のチェックを行う
    # ^ chatGpt: 編集フォームにデフォルト値や事前入力されたデータが必要ないのであれば、editアクションで引数なしでフォームオブジェクトを初期化してもまったく問題ありません。
    # @change_password_form = Staff::ChangePasswordForm.new
    @change_password_form = Staff::ChangePasswordForm.new(object: current_staff_member)
  end

  def update
    # ¥ staff_member_params は キーワード引数 =>
      # {
      #   current_password: "oldpassword123",
      #   new_password: "newpassword123",
      #   new_password_confirmation: "newpassword123"
      # }
    @change_password_form = Staff::ChangePasswordForm.new(staff_member_params)
    #! setter を呼び出している 右辺に = がついているため
    @change_password_form.object = current_staff_member
    # ! .saveはmodelクラスのsaveメソッドではなく、 change_password_form.rb の中の def save; object.password = new_password; object.save!; end  を呼び出してその中で current_staff_member の属性(新しいpassword)を保存している
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
  # ¥ 結果例:
  # {
  #   current_password: "oldpassword123",
  #   new_password: "newpassword123",
  #   new_password_confirmation: "newpassword123"
  # }
end

# - 20230810
# Rubyでは、クラスに対して明示的にinitializeメソッドを定義しない場合、そのクラスはスーパークラスのinitializeメソッドを継承します。この場合、スーパークラスは Object であり（他に何も指定されていない場合）、デフォルトの initialize メソッドは特に何も行いません。

#- しかし、提供されたコードでは、Staff::ChangePasswordForm に ActiveModel::Model が含まれています。クラスにActiveModel::Modelモジュールをインクルードすると、そのクラスはRailsのモデルで使われるいくつかの機能を手に入れることができます。

# - .new(object: current_staff_member)を使ってStaff::ChangePasswordFormのオブジェクトをインスタンス化できるのはこのためです。Staff::ChangePasswordForm クラスがハッシュで初期化されると、ActiveModel::Model はハッシュのキーにちなんだインスタンス変数を対応する値に自動的に設定する機能を提供します。以下はその内訳です：
# ¥ 流れ:
# 1. Staff::ChangePasswordForm.new(object: current_staff_member) が呼び出されます。
# 2. ActiveModel::Model のコードは :object の attr_accessor が存在し、与えられたハッシュに :object というキーがあることを確認します。
# 3. 値 current_staff_member は新しい Staff::ChangePasswordForm オブジェクトの @object インスタンス変数に代入されます。
# 4. 新しい Staff::ChangePasswordForm オブジェクト (@object に current_staff_member が設定されている) が返されます。
# 5. クラスの他の attr_accessor メソッドと一致するキーがハッシュ内にある場合、それらのインスタンス変数も同様の方法で設定されます。一致する attr_accessor がない場合、ハッシュの属性は無視されます。

# ActiveModel::Modelが提供するこの動作は、特にRailsアプリケーションのフォームオブジェクトやその他のサービスオブジェクトで、定型的なコードを減らすのに役立つので非常に便利です。