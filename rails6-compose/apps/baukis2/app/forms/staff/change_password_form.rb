class Staff::ChangePasswordForm
  #- しかし、提供されたコードでは、Staff::ChangePasswordForm に ActiveModel::Model が含まれています。クラスにActiveModel::Modelモジュールをインクルードすると、そのクラスはRailsのモデルで使われるいくつかの機能を手に入れることができます。

  # - .new(object: current_staff_member)を使ってStaff::ChangePasswordFormのオブジェクトをインスタンス化できるのはこのためです。Staff::ChangePasswordForm クラスがハッシュで初期化されると、ActiveModel::Model はハッシュのキーにちなんだインスタンス変数を対応する値に自動的に設定する機能を提供します。
  include ActiveModel::Model

  # - :object:    20230810
  # - Creates a method object which returns the value of @object.
  # - Creates a method object=(value) which sets the value of @object to value.
  attr_accessor :object, :current_password, :new_password,
    :new_password_confirmation

  # ¥ attr_accessor :object is equivalent to defining the following two methods:
  # def object
  # @object
  # end

  # def object=(value)
  # @object = value
  # end

  # ¥ confirmation: true - new_passwordの値がnew_password_confirmationの値と一致することを保証する。
  # -new_password 属性に対して confirmation タイプのバリデーションを設定しています。この場合、この属性の名前に_confirmation を付加した名前を持つ属性とを比較して、値が一致しなければバリデーションが失敗する 20230810
  validates :new_password, presence: true, confirmation: true

  # ¥ ※validatesではない!  /  クラスメソッド validate は、 presence や form などの組み込みバリデーション以外の方式でバリデーションを実装するときに利用します。 Staff::Authenticatorを用いてユーザーが入力した「現在のパスワード」が正しいかどうかをチェックしています
  validate do
    unless Staff::Authenticator.new(object).authenticate(current_password)
      errors.add(:current_password, :wrong)
    end
  end

  # ¥ attr_accessor :object is equivalent to defining the following two methods:
  # def object
  # @object
  # end

  # def object=(value)
  #   @object = value
  # end
  # ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥

  def save
    # object.password = new_password
    # object.save!
    if valid?
      object.password = new_password
      object.save!
    end
  end
end

#  20230809
# ¥ActiveModel::Model モジュールを include することにより Staff::ChangePassword<br />Form クラスを非Active Recordモデルにしています。クラスメソッド attr_accessor で4つの属性を定義しています。 object 属性にはこのフォームオブジェクトが取り扱う StaffMember オブジェクトをセットします。その他の3つの属性はフォームの入力欄（フィールド）を生成する際に使われます。ユーザーは current_password フィールドに現在のパスワードを入力します。

# ¥ また、 new_password フィールドと new_password_confirmation フィールドには新しいパスワードとして同一の文字列を入力することになります。 Chapter 8で作成したフォームオブジェクト Staff::LoginForm と異なり、 Staff::ChangePasswordForm クラスには save メソッドを定義します。 ActiveModel::Model モジュールを include して作られた非Active Recordモデルには save メソッドは存在しません。フォームオブジェクトの本来の役割は、 form_with メソッドの model オプションの値として指定されることです。しかし、ここでは付随的な機能として、フォームオブジェクトが取り扱うオブジェクトを保存するメソッドを追加しています。

# ¥ save メソッドの中身は単純です。

#- object.password = new_password
#- object.save!

# ¥ object 属性にセットされている StaffMember オブジェクトに新しいパスワードを設定し、データベースに保存しています。まだバリデーションの機能はありません（後ほど作ります）。現在のパスワードが合っていなくても、2回入力した新しいパスワードが合致しなくても、そのままパスワードを変更します。

