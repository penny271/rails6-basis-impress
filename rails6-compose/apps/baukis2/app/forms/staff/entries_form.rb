# ¥ 2.ch.7.3.2
class Staff::EntriesForm
  include ActiveModel::Model

  attr_accessor :program, :approved, :not_approved, :canceled, :not_canceled

  def initialize(program)
    @program = program
  end

  # ¥ 2.ch.7.3.3 多数のオブジェクトの一括更新処理
  def update_all(params)
    assign_attributes(params)
    save
  end

  private def assign_attributes(params)
    puts("entries_form_params: #{params}")
    #結果例: entries_form_params: {"_method"=>"patch", "authenticity_token"=>"+i37EVd40BFpAdCqWnpkbdCRsc3d2/fztQM6q5PELNuED36Kb0nw6OjwqYhJOjd0Ygo0ar7+s4sIBgKjjWv32A==", "form"=>{"approved"=>"16:17:22:25:26:27:28:29", "not_approved"=>"18:19:20:21:23:24:30", "canceled"=>"17:18:19:20:21:23:24:30", "not_canceled"=>"16:22:25:26:27:28:29"}, "host"=>"baukis2.example.com", "controller"=>"staff/entries", "action"=>"update_all", "program_id"=>"17"}
    fp = params.require(:form).permit([
      :approved, :not_approved, :canceled, :not_canceled
    ])

    @approved = fp[:approved]
    @not_approved = fp[:not_approved]
    @canceled = fp[:canceled]
    @not_canceled = fp[:not_canceled]
  end

  private def save
    approved_entry_ids = @approved.split(":").map(&:to_i)
    not_approved_entry_ids = @not_approved.split(":").map(&:to_i)
    canceled_entry_ids = @canceled.split(":").map(&:to_i)
    not_canceled_entry_ids = @not_canceled.split(":").map(&:to_i)

    ActiveRecord::Base.transaction do
      @program.entries.where(id: approved_entry_ids)
        .update_all(approved: true) if approved_entry_ids.present?
      @program.entries.where(id: not_approved_entry_ids)
        .update_all(approved: false) if not_approved_entry_ids.present?
      @program.entries.where(id: canceled_entry_ids)
        .update_all(canceled: true) if canceled_entry_ids.present?
      @program.entries.where(id: not_canceled_entry_ids)
        .update_all(canceled: false) if not_canceled_entry_ids.present?
    end
  end

end

