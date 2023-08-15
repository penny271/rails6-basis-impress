module ApplicationHelper
  # ¥ 20230811 ERBテンプレート内で markupメソッドを使えるようにする = ヘルパーメソッドを作成
  include HtmlBuilder

  def document_title
    if @title.present?
      "#{@title} - Baukis2"
    else
      "Baukis2"
    end
  end
end
