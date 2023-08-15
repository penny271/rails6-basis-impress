#- inde.html.erb - StaffMemberPresenter クラスのインスタンスを作成しています。 new メソッドには2つの引数を指定します。第1引数は StaffMember オブジェクトです。第2引数には擬似変数 self を指定します。
#- ERBテンプレートの中で self によって参照されるオブジェクトを ビューコンテキスト と呼びます。このオブジェクトは Rails で定義されたすべてのヘルパーメソッドを自分のメソッドとして持っています。
#- StaffMemberPresenter クラスは ModelPresenter クラスを継承しているため、2つの属性を所有しています。 object 属性と view_context 属性です。前者には StaffMember オブジェクト、後者にはビューコンテキストがセットされます
# ¥ object 属性と view_context 属性です。前者には StaffMember オブジェクト、後者にはビューコンテキスト(self)がセットされます

# - ModelPresenterで下記のようにしているため 本ファイルでobjectを使える
# delegate :raw, :link_to, to: :view_context
# attr_reader :object, :view_context
#   def initialize(object, view_context)
# @object = object
# @view_context = view_context
# end

class StaffMemberPresenter < ModelPresenter

  # - delegateクラスメソッドで簡略化できる
  delegate :suspended?, to: :object

  def full_name
    object.family_name + " " + object.given_name
  end

  def full_name_kana
    object.family_name_kana + " " + object.given_name_kana
  end

  # 職員の停止フラグのOn/Offを表現する記号を返す。
  # On: BALLOT BOX WITH CHECK (U+2611)
  # Off: BALLOT BOX (U+2610)
  def suspended_mark
    # ¥ .row()文字列をエスケープしない
    # ^ オリジナル: <%= m.suspended? ? raw("&#x2611;") : raw("&#x2610;") %>
    # object.suspended? ? view_context.raw("&#x2611;") : view_context.raw("&#x2610;")
    # object.suspended? ? raw("&#x2611;") : raw("&#x2610;")
    suspended? ? raw("&#x2611;") : raw("&#x2610;")
  end
end
#- 変数 m を属性 object で置き換えています。そしてヘルパーメソッド raw の前に view_context とドット記号を付加しています。 モデルプレゼンターは raw メソッドを持っていませんので、そのまま raw("&amp;#x2611;") と書けばエラーになります。しかし、モデルプレゼンターの view_context 属性にはビューコンテキストがセットされていて、ビューコンテキストは raw メソッドを含むすべてのヘルパーメソッドを持っています。したがって、このように view_context 属性経由で raw メソッドを呼び出せるわけです



