#- inde.html.erb - StaffMemberFormPresenter クラスのインスタンスを作成しています。 new メソッドには2つの引数を指定します。第1引数は StaffMember オブジェクトです。第2引数には擬似変数 self を指定します。
#- ERBテンプレートの中で self によって参照されるオブジェクトを ビューコンテキスト と呼びます。このオブジェクトは Rails で定義されたすべてのヘルパーメソッドを自分のメソッドとして持っています。
#- StaffMemberFormPresenter クラスは ModelPresenter クラスを継承しているため、2つの属性を所有しています。 object 属性と view_context 属性です。前者には StaffMember オブジェクト、後者にはビューコンテキストがセットされます
# ¥ object 属性と view_context 属性です。前者には StaffMember オブジェクト、後者にはビューコンテキスト(self)がセットされます
class StaffMemberFormPresenter < UserFormPresenter
  def suspended_check_box
    markup(:div, class: "input-block") do |m|
      m << check_box(:suspended)
      m << label(:suspended, "アカウント停止")
    end
  end
end
