# ¥ 2.ch5.2.2 許可IPアドレスの管理
# class Admin::AllowedSourcesController < ApplicationController
class Admin::AllowedSourcesController < Admin::Base
  def index
    @allowed_sources = AllowedSource.where(namespace: "staff").order(:octet1, :octet2, :octet3, :octet4)
    @new_allowed_source = AllowedSource.new
  end

  def create
    @new_allowed_source = AllowedSource.new(allowed_source_params)
    @new_allowed_source.namespace = "staff"

    if @new_allowed_source.save
      flash.notice = "許可IPアドレスを追加しました。"
      redirect_to action: "index"
    else
      @allowed_sources = AllowedSource.order(:octet1, :octet2, :octet3, :octet4)
      flash.now.alert = "許可IPアドレスの値が正しくありません。"
      render action: "index"
    end
  end

  # ¥ 2.ch5.2.7 許可IPアドレスの一括削除
  def delete
    if Admin::AllowedSourcesDeleter.new.delete(params[:form])
      flash.notice = "許可IPアドレスを削除しました。"
    end
      redirect_to action: "index"
  end

  private def allowed_source_params
    # - :last_octet は _new_allowed_source.html.erb で使用したカスタム属性(dbにない属性)
    params.require(:allowed_source)
      .permit(:octet1, :octet2, :octet3, :last_octet)
  end
end
