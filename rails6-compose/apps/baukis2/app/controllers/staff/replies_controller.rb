# ¥ 2.ch.12.1.3 タグ付け
# class Staff::RepliesController < ApplicationController
class Staff::RepliesController < Staff::Base
  before_action :prepare_message

  def new
    @reply = StaffMessage.new
  end

  # ¥ 2.ch.12.1.4 タグ付け
  def confirm
    @reply = StaffMessage.new(staff_message_params)
    @reply.staff_member = current_staff_member
    @reply.parent = @message
    if @reply.valid?
      render action: "confirm"
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "new"
    end
  end

  # ¥ 2.ch.12.1.4 タグ付け
  # * 職員が確認画面で「送信」ボタンをクリックした場合には commit パラメータが存在しています。「訂正」ボタンがクリックされた場合には、返信の編集フォームが表示されます。
  # ! <%= f.submit "送信" %> のデフォルトの タグの name属性は commit である(自動的にそうなる)
  def create
    @reply = StaffMessage.new(staff_message_params)
    if params[:commit]
      @reply.staff_member = current_staff_member
      @reply.parent = @message
      if @reply.save
        flash.notice = "問い合わせに返信しました。"
        redirect_to :outbound_staff_messages
      else
        flash.now.alert = "入力に誤りがありませす。"
        render action: "new"
      end
    else
      render action: "new"
    end
  end

  # ¥このコントローラは messages リソースにネストされているので、必ず message_id パラメータがアクションに届きます。 before_action に指定された prepare_message メソッドで、この値を用いてインスタンス変数 @message に、 CustomerMessage オブジェクトをセットしておきましょう
  private def prepare_message
    @message = CustomerMessage.find(params[:message_id])
  end

  # ¥ 2.ch.12.1.4 タグ付け
  private def staff_message_params
    # * new.html.erb の <%= form_with model: @reply, url: confirm_staff_message_reply_path(@message) do |f| %> の @replyから require(:staff_message) が来ている
    # - @reply = StaffMessage.new(staff_message_params)
    params.require(:staff_message).permit(:subject, :body)
  end
end
