class Staff::Authenticator
  def initialize(staff_member)
    @staff_member = staff_member
  end

  #! if文不要 - 短絡評価を使っているため 解説: Rubyでは、すべての式は値を返します。この場合、authenticateメソッドは、メソッド内のすべての条件が満たされればtrueを返し、そうでなければfalseを返します。
  # ¥ これらの条件がすべて真なら、メソッドは真を返す。これらの条件のどれかが偽なら、メソッドは偽を返す。言い換えれば、短絡評価を使って、どれかひとつが偽になった時点で条件のチェックをやめているのであり、if文に似ている。
  def authenticate(raw_password)
    @staff_member &&
      @staff_member.hashed_password &&
      @staff_member.start_date <= Date.today &&
      (@staff_member.end_date.nil? || @staff_member.end_date > Date.today) &&
      BCrypt::Password.new(@staff_member.hashed_password) == raw_password
  end
end # end of class Staff::Authenticator

# ¥ 8.2　 サービスオブジェクト サービスオブジェクト（service objects）も、フォームオブジェクトと同様にRailsコミュニティの中で生み出された概念です。サービスオブジェクトはアクションと同様に、あるまとまった処理を行います。ただし、コントローラのインスタンスメソッドとして実装されるのではなく、独立したクラスとして実装されます。この節では、職員をユーザーとして認証するサービスオブジェクトStaff::Authenticatorを作ります。

