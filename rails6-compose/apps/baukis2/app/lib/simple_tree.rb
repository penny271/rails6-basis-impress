# ¥ 2.ch.11.3.2 ツリー構造 パフォーマンス向上策
class SimpleTree
  attr_reader :root, :nodes

  def initialize(root, descendants)
    @root = root
    @descendants = descendants

    @nodes = {}
    ([ @root ] + @descendants).each do |d|
      d.child_nodes = []
      @nodes[d.id] = d
    end

    @descendants.each do |d|
      @nodes[d.parent_id].child_nodes << @nodes[d.id]
    end
  end
end

# *SimpleTree のコンストラクタの第1引数にはルートオブジェクト、第2引数にはその子孫オブジェクトの配列を渡します。8-12行ではツリーに属するすべてのオブジェクトを値として持つハッシュ @nodes を作っています。このハッシュのキーはオブジェクトの主キーの値です。ハッシュを作りながら、各オブジェクトの child_nodes 属性に空の配列をセットしています。まだ、 Message モデルには child_nodes 属性はありませんが、あとで定義します。14-16行では、各子孫オブジェクトをその親オブジェクトの child_nodes 属性（配列）に追加しています。