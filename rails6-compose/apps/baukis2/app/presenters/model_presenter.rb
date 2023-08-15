class ModelPresenter
  include HtmlBuilder

  # ¥ 20230810 呼び出し専用の属性を定義する getterの設定
  #- attr_reader宣言により、ModelPresenterのインスタンスから@objectと@view_contextの値をそれぞれobjectとview_contextのメソッドを使って取得できるようになりました。
  attr_reader :object, :view_context
  #  - クラスメソッド delegate は引数に指定された名前のインスタンスメソッドを定義します。そして、そのインスタンスメソッドの働きは、 to オプションに指定されたメソッドが返すオブジェクトに委ねられます。つまり、ここでは raw という名前のメソッドを ModelPresenter のインスタンスメソッドとして定義しているのですが、その働きは view_context メソッドが返すオブジェクトに委譲されるのです。 view_context メソッドが返すオブジェクトは、ビューコンテキストです。ビューコンテキストはすべてのヘルパーメソッドを所有しているので、当然ながら raw メソッドも持っています。結局のところ、 ModelPresenter のインスタンスメソッド raw が呼ばれると、ヘルパーメソッド raw が呼び出されることになるわけです。
  # delegate :raw, to: :view_context
  #^  この宣言は、raw, link_to などのメソッドを定義し、これらのメソッドが呼び出されたら、@form_builderの対応するメソッドにメソッド呼び出しと引数を委譲する（渡す）ことをクラスに指示しています。
  delegate :raw, :link_to, to: :view_context

  def initialize(object, view_context)
    @object = object
    @view_context = view_context
  end

  def created_at
    # - &. ボッチ演算子とほぼ同じ .try()  NoMethodErrorを防ぐ役割 代わりにnilを返す
    object.created_at.try(:strftime, "%Y/%m/%d %H:%M:%S")
  end

  def updated_at
    object.updated_at.try(:strftime, "%Y/%m/%d %H:%M:%S")
  end

end
