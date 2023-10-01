# ¥ 2.ch.10.2.2 問い合わせ到着の通知 ajax
# - 本書におけるこれまでのコントローラの作り方と異なり、 Staff::AjaxController は Staff::Base ではなく、 ApplicationController を継承しています。なぜでしょうか。それは、ブラウザがこのコントローラのアクションを呼び出す権限がないときに、サーバーが返すべきレスポンスが異なるからです
class Staff::AjaxController < ApplicationController
  before_action :check_source_ip_address
  before_action :authorize
  before_action :check_timeout
  # ¥ 2.ch.10.2.5 問い合わせ到着の通知 ajax
  before_action :reject_non_xhr # - application_controllerから呼び出す

  # GET
  def message_count
    render plain: CustomerMessage.unprocessed.count
  end

  # ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
  # POST
  def add_tag
    message = Message.find(params[:id])
    message.add_tag(params[:label])
    render plain: "ok"
  end

  # ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
  # DELETE
  def remove_tag
    message = Message.find(params[:id])
    message.remove_tag(params[:label])
    render plain: "ok"
  end

  private def check_source_ip_address
    unless AllowedSource.include?("staff", request.ip)
      render plain: "Forbidden", status: 403
    end
  end

  private def current_staff_member
    if session[:staff_member_id]
      StaffMember.find_by(id: session[:staff_member_id])
    end
  end

  private def authorize
    unless current_staff_member && current_staff_member.active?
      render plain: "Forbidden", status: 403
    end
  end

  private def check_timeout
    unless session[:last_access_time] &&
           session[:last_access_time] >= Staff::Base::TIMEOUT.ago
      session.delete(:staff_member_id)
      render plain: "Forbidden", status: 403
    end
  end
end