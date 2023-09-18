# ¥ 2.ch.7.3.3 多数のオブジェクトの一括更新処理
# class Staff::EntriesController < ApplicationController
class Staff::EntriesController < Staff::Base
  def update_all
    entries_form = Staff::EntriesForm.new(Program.find(params[:program_id]))
    entries_form.update_all(params)
    flash.notice = "プログラム申し込みのフラグを更新しました。"
    redirect_to :staff_programs
  end
end