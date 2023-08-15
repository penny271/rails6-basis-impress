  # - model_presenterより下記を継承しているため getterの仕様を利用してobjectメソッドを使うことができる => よって delegate: で to: :object とすることができる 20230813
  # attr_reader :object, :view_context
  # def initialize(object, view_context)
  #   @object = object
  #   @view_context = view_context
  # end

class StaffEventPresenter < ModelPresenter
  delegate :member, :description, :occurred_at, to: :object

  def table_row
    markup(:tr) do |m|
      #¥ 20230811 instance_variable_get は、レシーバが持っているインスタンス変数の値を取得するメソッドです。部分テンプレートのインスタンス変数@staff_member の値を取得しています。
      unless view_context.instance_variable_get(:@staff_member)
        m.td do
          m << link_to(member.family_name + member.given_name,
          [ :admin, member, :staff_events ])
        end
      end
      m.td description
      # <td><%= event.description %></td>
      m.td(:class => "date") do
        m.text occurred_at.strftime("%Y/%m/%d %H:%M:%S")
      end
    end
  end
end