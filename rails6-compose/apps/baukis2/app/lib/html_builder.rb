module HtmlBuilder
  def markup(tag_name = nil, options = {})
    root = Nokogiri::HTML::DocumentFragment.parse("")
    Nokogiri::HTML::Builder.with(root) do |doc|
      if tag_name
        #! method_missingを使わないと No method errorが起きる - docにはまだ .div等のメソッドははじめから存在していないため、 method_missingを使うことによって動的に要素を作成できる!
        # ¥ Nokogiri::HTML::Builderのmethod_missingアプローチは、メソッド名に基づいた動的なタグ生成を可能にし、HTML構造の作成に柔軟性と使いやすさを提供します。
        # - 例: doc.method_missing(:div, options) gets invoked. This means Nokogiri will create a <div> element.
        #! doc.method_missing(tag_name, options) で <div>タグを作成している その後の doのblock内で あとに続く要素(<input>等)をdivタグの中に生成している!
        doc.method_missing(tag_name, options) do
          # ¥ マークアップ・メソッドにyield(doc)とあるのは、"ここにブロックで生成されたコンテンツを入れなさい "と言っているのだと思ってください。
          yield(doc)
        end
      # - tag_nameを付けずに使用すると、タグを囲むことなくコンテンツを直接挿入することができます。どちらのアプローチも、提供されたブロックを使ってHTMLのコンテンツやさらなる入れ子構造を定義します。
      # 例 markup do |m|; m.span "Hello World"; end
      # <span>Hello World</span>
      else
        yield(doc)
      end
    end
    root.to_html.html_safe
  end
end

# ^ 20230813 データ属性も付与可能
#! Notice the { } around the class and data attributes, indicating that they are part of the same hash argument.
# html = markup(:div, { class: "inline-block", data: { sample: "データサンプル" } }) do |doc|
#   doc.span "Hello World"
# end

#- result: <div class="inline-block" data-sample="データサンプル"><span>Hello World</span></div>

# 20230813 本メソッドの流れ:
# Here's the sequence of events:

# Method Invocation: markup(:div,class: "input-block")を呼び出すとき、tag_nameは:div、optionsは{class： "input-block"}.

# ビルド処理の開始 マークアップメソッドの中で、Nokogiri::HTML::Builder.with(root)がHTMLの構築プロセスを開始します。どのようなHTMLが構築されるべきかを決定するコードのブロックを取る。

# メソッドを動的に呼び出す ビルド処理の中で、doc.method_missing(tag_name, options)が呼び出される。Here, tag_name is :div. So, this is equivalent to dynamically calling doc.div(options).

# なぜなら、Nokogiri::HTML::Builderは各HTML要素（div、span、aなど）に対してあらかじめ定義されたメソッドを持っていないので、Rubyのmethod_missingを使ってこれらのメソッド呼び出しを動的に処理するからです。 When you "call" a method that doesn't exist on the doc object (which is an instance of Nokogiri::HTML::Builder), it treats the method name as the name of an HTML tag and tries to create an element with that name.

# つまり、doc.div(...)を "呼び出す "と、定義済みのdivメソッドがないにもかかわらず、Nokogiri::HTML::Builderは<div>要素を作りたいのだと理解します。

# Inserting Content Inside the Element:
# ここでdoc.method_missing(tag_name, options)に渡されるブロック（つまり、do ... endブロックの中）は、作成された<div>の中に入るべき内容です。 ここでyield(doc)が登場します。 By yielding the doc, you're giving the caller of markup the opportunity to specify what should be inside the <div>.

# Completing the <div> Element:
# 一旦doc.method_missing(tag_name, options)のdo ... endブロック内の内容が実行されると、<div>タグは完成したとみなされます。

# Returning the HTML: Finally, root.to_html.html_safe converts the constructed document fragment into an HTML string that's safe to render in views.

# では、ご質問に直接お答えしましょう：
# The <div> is created when doc.method_missing(tag_name, options) is invoked. The content inside the <div> is determined by what's inside the do ... end block for that method call, and the <div> tag is completed once that block is finished executing.

# ¥ 20230811 ブロック変数 m には Nokogiri::HTML::Builder オブジェクトがセットされます。このオブジェクトに対して div や span のようなHTMLタグに対応するメソッドを呼び出すと、このオブジェクトの中にHTML要素が追加されていきます。メソッドの引数に指定された文字列はHTML要素の中身になります。また、メソッドに指定したオプションはHTML要素の属性となります。 Nokogiri::HTML::Builder オブジェクトの text メソッドは、タグで囲まれていないテキスト（テキストノード）を追加します。 markup メソッドの戻り値は、ブロック変数に追加されたHTML要素全体に対応する文字列です。 次に示すのはネストされたHTMLコードを生成する例
# markup do|m|
#   m.div(class:"notes") do
#     m.span "*", class: "mark"
#     m.text "印の付いた項目は入力必須です。"
#   end
# end

#¥ Nokogiri::HTML::Builder オブジェクトに、生成済みのHTMLコードの断片を加える場合は << メソッドを使用します。
# markup do |m|
#   m << "<span class='mark'>*</span>"
#   m.text "印の付いた項目は入力必須です。"
# end

