class Staff::ChangePasswordForm
  include ActiveModel::Model

  # - 20230809 このファイルを通じて、passwords_controller.rb が objectにcurrent_staff_member を入れて @change_password_formを 生成している
  # def edit
  #   # ¥ object属性に職員本人のStaffMemberオブジェクトを指定してフォームオブジェクトを生成している 20230809
  #   @change_password_form = Staff::ChangePasswordForm.new(object: current_staff_member)
  # end

  attr_accessor :object, :current_password, :new_password,
    :new_password_confirmation

  def save
    object.passowrd = new_password
    object.save!
  end
end

#  20230809
# ¥ActiveModel::Model モジュールを include することにより Staff::ChangePassword<br />Form クラスを非Active Recordモデルにしています。クラスメソッド attr_accessor で4つの属性を定義しています。 object 属性にはこのフォームオブジェクトが取り扱う StaffMember オブジェクトをセットします。その他の3つの属性はフォームの入力欄（フィールド）を生成する際に使われます。ユーザーは current_password フィールドに現在のパスワードを入力します。

# ¥ また、 new_password フィールドと new_password_confirmation フィールドには新しいパスワードとして同一の文字列を入力することになります。 Chapter 8で作成したフォームオブジェクト Staff::LoginForm と異なり、 Staff::ChangePasswordForm クラスには save メソッドを定義します。 ActiveModel::Model モジュールを include して作られた非Active Recordモデルには save メソッドは存在しません。フォームオブジェクトの本来の役割は、 form_with メソッドの model オプションの値として指定されることです。しかし、ここでは付随的な機能として、フォームオブジェクトが取り扱うオブジェクトを保存するメソッドを追加しています。

# ¥ save メソッドの中身は単純です。

#- object.password = new_password
#- object.save!

# ¥ object 属性にセットされている StaffMember オブジェクトに新しいパスワードを設定し、データベースに保存しています。まだバリデーションの機能はありません（後ほど作ります）。現在のパスワードが合っていなくても、2回入力した新しいパスワードが合致しなくても、そのままパスワードを変更します。

