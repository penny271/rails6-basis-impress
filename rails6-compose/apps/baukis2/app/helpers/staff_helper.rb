# ¥ 2.ch.10.2.2 問い合わせ到着の通知 ajax
module StaffHelper
  include HtmlBuilder

  # - .unprocessed は customer_message.rb で作った scope名
  def number_of_unprocessed_messages
    markup do |m|
      # m.a(href: "#") do
      # - ¥ 2.ch.11.1.2 ツリー構造
      m.a(href: inbound_staff_messages_path) do
        m << "新規問い合わせ"
        anchor_text =
          if (c = CustomerMessage.unprocessed.count) > 0
            "(#{c})"
          else
            ""
          end
        m.span(
          anchor_text,
          id: "number-of-unprocessed-messages",
          "data-path" => staff_messages_count_path
        )
      end
    end
  end
end

#- in routes.rbの中で namespace :staff / get "messages/count" => "ajax#message_count" としているので "data-path" => staff_messages_count_path　というhelper method(staff_messages_count_path)を使える