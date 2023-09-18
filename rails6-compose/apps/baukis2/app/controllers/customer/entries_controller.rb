# ¥ 2.ch.8.2.3 プログラム一覧表示・詳細表示機能(顧客向け)
# class Customer::EntriesController < ApplicationController
class Customer::EntriesController < Customer::Base
  def create
    # ^ :published は program.rbより使用可能
    #   scope :published, -> {
  #   where("application_start_time <= ?", Time.current).order("application_start_time DESC")
  # }
    program = Program.published.find(params[:program_id])
    #  - programと紐づいた entries レコードを作成している
    # program.entries.create!(customer: current_customer)
    # flash.notice = "プログラムに申し込みました。"
    # if max = program.max_number_of_participants
    #   if program.entries.where(canceled: false).count < max
    #     program.entries.create!(customer: current_customer)
    #     flash.notice = "プログラムに申し込みました。"
    #   else
    #     flash.alert = "プログラムへの申込者数が上限に達しました。"
    #   end
    # else
    #   program.entries.create!(customer: current_customer)
    #   flash.notice = "プログラムに申し込みました。"
    # end
    case Customer::EntryAcceptor.new(current_customer).accept(program)
    when :accepted
      flash.notice = "プログラムに申し込みました。"
    when :full
      flash.alert = "プログラムへの申込者数が上限に達しました。"
    when :closed
      flash.alert = "プログラムの申込期間が終了しました。"
    end
    redirect_to [ :customer, program ]
  end

  # ¥ 2.ch.8.4.4 申込みのキャンセル
  # PATCH
  def cancel
    program = Program.published.find(params[:program_id])
    if program.application_end_time.try(:<, Time.current)
      flash.alert = "プログラムへの申し込みをキャンセルできません（受付期間終了）。"
    else
      entry = program.entries.find_by!(customer_id: current_customer.id)
      # * update_columnメソッドはActiveRecordのメソッドで、モデルのコールバックやバリデーション、updated_at/updated_onタイムスタンプをトリガーすることなく、データベース内の単一のカラムの値を直接更新するために使われます。
      entry.update_column(:canceled, true)
      flash.notice = "プログラムへの申し込みをキャンセルしました。"
    end
    redirect_to [ :customer, program ]
  end
end
