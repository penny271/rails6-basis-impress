# class Customer::MessagesController < ApplicationController
class Customer::MessagesController < Customer::Base
  # ¥ 2.ch.12.5演習問題
  def index
    @messages = current_customer.inbound_messages.sorted.page(params[:page])
  end

  # ¥ 2.ch.12.5演習問題
  def show
    @message = current_customer.inbound_messages.find(params[:id])
  end

  def new
    @message = CustomerMessage.new
  end

  # ¥ 2.ch.10.1.7 Ajax 顧客向け問い合わせフォーム
  # POST
  def confirm
    @message = CustomerMessage.new(customer_message_params)
    @message.customer = current_customer
    if @message.valid?
      render action: "confirm"
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "new"
    end
  end

  # ¥ 2.ch.10.1.7 Ajax 顧客向け問い合わせフォーム
  def create
    @message = CustomerMessage.new(customer_message_params)
    # * フォームビルダーの submit メソッドには name オプションを与えることができます。これは input 要素の name 属性の値として用いられます。 name オプションのデフォルト値が "commit" です。フォームが送信されると、クリックされたボタンの name 属性をキーとするパラメータも同時に送信されます。つまり、「送信」ボタンがクリックされると "commit" というキーのパラメータが、「訂正」ボタンがクリックされると、"correct" というキーのパラメータが update アクションに渡ります。 したがって、 params[:commit] に値がセットされているかどうかで、どちらのボタンが押されたのかが判定できるというわけです
    if params[:commit]
      @message.customer = current_customer
      if @message.save
        flash.notice = "問い合わせを送信しました。"
        redirect_to :customer_root
      else
        flash.now.alert = "入力に誤りがあります。"
        render action: "new"
      end
    else
      render action: "new"
    end
  end

  private def customer_message_params
    params.require(:customer_message).permit(:subject, :body)
  end

  # ¥ 2.ch.12.5演習問題 3
  def destroy
    message = current_customer.inbound_messages.find(params[:id])
    message.update_column(:discarded, true)
    flash.notice = "メッセージを削除しました。"
    redirect_back(fallback_location: :customer_message)
  end
end
