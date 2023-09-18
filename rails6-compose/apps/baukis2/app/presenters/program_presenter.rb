# ¥ 2.ch6.2
class ProgramPresenter < ModelPresenter
  delegate :title, :description, to: :object
  # delegate :number_with_delimiter, to: :view_context
  # ¥ 2.ch.8.2.2 プログラム一覧表示・詳細表示機能(顧客向け)
  # delegate :number_with_delimiter, :button_to, to: :view_context
  # ¥ 2.ch.8.4.4 申込みのキャンセル
  delegate :number_with_delimiter, :button_to, :current_customer, to: :view_context

  def application_start_time
    object.application_start_time.strftime("%Y-%m-%d %H:%M")
  end

  def application_end_time
    object.application_end_time.strftime("%Y-%m-%d %H:%M")
  end

  def max_number_of_participants
    if object.max_number_of_participants
      # - number_with_delimiter - 引数に与えられた数値に3桁区切りのコンマを追加するヘルパーメソッド
      number_with_delimiter(object.max_number_of_participants)
    end
  end

  def min_number_of_participants
    if object.min_number_of_participants
      number_with_delimiter(object.min_number_of_participants)
    end
  end

  def number_of_applicants
    # number_with_delimiter(object.entries.count)
    # ¥ 2.ch6.3.4 program.rb(models) の scopeで新しい擬似的なカラムを作成している
    number_with_delimiter(object[:number_of_applicants])
  end

  def registrant
    object.registrant.family_name + " " + object.registrant.given_name
  end

  # ¥ 2.ch.8.2.2 プログラム一覧表示・詳細表示機能(顧客向け)
  def apply_or_cancel_button
    # ¥ 2.ch.8.4.4 申込みのキャンセル
    # if false
    if entry = object.entries.find_by(customer_id: current_customer.id)
      status = cancellation_status(entry)
      # - button_to メソッドの第2引数には、 cancel アクションのURLを生成するための配列を指定しています。配列の各要素は順に、アクション名、名前空間、 Program オブジェクト、 Entry オブジェクトです。アクション名を先頭に記述する点に注意してください。
      button_to cancel_button_label_text(status), [ :cancel, :customer, object, :entry], disabled: status != :cancellable, method: :patch, data: { confirm: "本当にキャンセルしますか? "}
    else
      status = program_status
      button_to button_label_text(status), [ :customer, object, :entry ],
        disabled: status != :available, method: :post,
        data: { confirm: "本当に申し込みますか？ " }
    end
  end

  private def program_status
    if object.application_end_time.try(:<, Time.current)
      :closed
    elsif object.max_number_of_participants.try(:<=, object.applicants.count)
      :full
    else
      :available
    end
  end

  private def button_label_text(status)
    case status
    when :closed
      "募集終了"
    when :full
      "満員"
    else
      "申し込む"
    end
  end

  # ¥ 2.ch.8.4.4 申込みのキャンセル
  private def cancellation_status(entry)
    if object.application_end_time.try(:<, Time.current)
      :closed
    elsif entry.canceled?
      :canceled
    else
      :cancellable
    end
  end

  # ¥ 2.ch.8.4.4 申込みのキャンセル
  private def cancel_button_label_text(status)
    case status
    when :closed
      "申し込み済み（キャンセル不可）"
    when :canceled
      "キャンセル済み"
    else
      "キャンセルする"
    end
  end
end