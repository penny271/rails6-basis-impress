# ¥ 2.ch.11.1.3 ツリー構造
# class Staff::MessagesController < ApplicationController
class Staff::MessagesController < Staff::Base
  def index
    # * message.rb の scopeを使用している
    # @messages = Message.not_deleted.sorted.page(params[:page])
    # ¥ 2.ch.12.3.3 タグ付け
    # * このアクションは、staff/tagsリソースにネストされて呼び出される場合とそうでない場合があります。その区別はtag_idパラメータの有無で分かります。
    # * messages_tag_linksテーブルのカラムの値に基づいてmessagesテーブルを絞り込むため、messages_tag_linksテーブルを結合（join）しています。
    # if params[:tag_id]
    #   @messages = @messages.joins(:message_tag_links).where("message_tag_links.tag_id" => params[:tag_id])
    # end

    # ¥ 2.ch.12.3.5 タグ付け - 引数を取るスコープ
    @messages = Message.not_deleted.sorted.page(params[:page]).tagged_as(params[:tag_id])
  end

  # GET
  def inbound
    # @messages = CustomerMessage.not_deleted.sorted.page(params[:page])
    # ¥ 2.ch.12.3.5 タグ付け - 引数を取るスコープ
    @messages = CustomerMessage.not_deleted.sorted.page(params[:page]).tagged_as(params[:tag_id])
    render action: "index"
  end

  # GET
  def outbound
    # @messages = StaffMessage.not_deleted.sorted.page(params[:page])
    # ¥ 2.ch.12.3.5 タグ付け - 引数を取るスコープ
    @messages = StaffMessage.not_deleted.sorted.page(params[:page]).tagged_as(params[:tag_id])
    render action: "index"
  end

  # GET
  def deleted
    # @messages = Message.deleted.sorted.page(params[:page])
    # ¥ 2.ch.12.3.5 タグ付け - 引数を取るスコープ
    @messages = Message.deleted.sorted.page(params[:page]).tagged_as(params[:tag_id])
    render action: "index"
  end

  # ¥ 2.ch.11.2.1 ツリー構造
  def show
    @message = Message.find(params[:id])
  end

  # * 他のコントローラの destroy アクションとは異なり、対象となる問い合わせをデータベースから完全に削除せずに deleted フラグを true にセットしています。この結果、その問い合わせは「ゴミ箱」に移動します。 redirect_back メソッドは、このアクションの呼び出し元のURLにリダイレクションを行います。Railsはリクエストヘッダ HTTP_REFERER の値を呼び出し元のURLとして使用します。このリクエストヘッダが設定されていない場合に備えて、 redirect_back メソッドの fallback_location オプションを指定します。このオプションは必須です
  def destroy
    message = CustomerMessage.find(params[:id])
    message.update_column(:deleted, true)
    flash.notice = '問い合わせを削除しました。'
    redirect_back(fallback_location: :staff_root)
  end

end
