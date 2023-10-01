# ¥ 2.ch.10.1.3 Ajax 顧客むけ問い合わせフォーム
# -メッセージと顧客、メッセージと職員との間の関連付けを行っています。メッセージが顧客からの問い合わせであれば、 customer が指すのはメッセージの送信者ですが、メッセージが職員からの返信であれば customer が指すのはメッセージの宛先です。また、メッセージのルート（ root）と親（ parent）との関連付けも宣言されています。顧客からの問い合わせの場合、 staff_member、 root、および parent は nil となるので、2番目以降の belongs_to メソッドには optional: true オプションを付けています。このオプションを省くと、例えば職員が割り当てられていないメッセージでバリデーションエラーが発生します。app/models ディレクトリに新規ファイル customer_message.rb を次のように作成します。このクラスが顧客からの問い合わせ（あるいは、返信の返信）を表現します
class Message < ApplicationRecord
  belongs_to :customer
  belongs_to :staff_member, optional: true
  belongs_to :root, class_name: "Message", foreign_key: "root_id",
    optional: true
  belongs_to :parent, class_name: "Message", foreign_key: "parent_id",
    optional: true

  # ¥ 2.ch.12.2.2 タグ付け
  has_many :message_tag_links, dependent: :destroy
  # * ここでは、第2引数にProcオブジェクト>{order(:value)}を指定しています。こうすることで、メッセージに付けられたタグの一覧を取得する際に、自動的にvalueカラムの値によってソートされます。
  has_many :tags, -> { order(:value) }, through: :message_tag_links

  # ¥ 2.ch.11.2.2 ツリー構造
  # * メッセージの詳細表示ページにメッセージツリーを表示します。準備作業として、あるメッセージに対する返信の集合を返す関連付け children を定義します
  # has_many :children, class_name: "Message", foreign_key: "parent_id", dependent: :destroy

  # ¥ 2.ch.10.1.4 Ajax 顧客向け問い合わせフォーム
  #  - before_validation ブロックには、 Message オブジェクトのバリデーションが実行される直前に実行されるべき処理を記述します。11行目では、親メッセージの customer をそれ自身の customer としてセットしています。12行目では、親メッセージの root をそれ自身の root にセットしています。ただし、親メッセージがルートである場合は root を持っていないので、親メッセージ自体を root にセットします
  before_validation do
    if parent
      self.customer = parent.customer
      self.root = parent.root || parent
    end
  end

  validates :subject, presence: true, length: { maximum: 80 } # 件名
  validates :body, presence: true, length: { maximum: 800 } # 本文

  # ¥ 2.ch.11.1.3 ツリー構造
  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }
  scope :sorted, -> { order(created_at: :desc) }

  # ¥ 2.ch.12.3.5 タグ付け - 引数を取るスコープ
  # * ここまでに登場した他のスコープとは異なり、このスコープtagged_asは引数を1個取ります。引数tag_idがnilでなければ、テーブルmessage_tag_linksを連結してtag_idで絞り込みます。引数tag_idがnilであれば、selfを返します。この場合、検索条件は追加されません。
  scope :tagged_as, -> (tag_id) do
    if tag_id
      joins(:message_tag_links).where("message_tag_links.tag_id" => tag_id)
    else
      self
    end
  end

  # ¥ 2.ch.11.3.2 ツリー構造 パフォーマンス向上策
  # * 関連付け children はもはや使わないので8-9行目を削除し、代わりにattr_accessor :child_nodesで child_nodes 属性を定義しています。先ほど見たように、この属性には配列がセットされ、子のリストを管理するために利用されます。25-30行では、 SimpleTree オブジェクトを返す tree メソッドを定義しています。本編7-3-2項で説明した遅延初期化のテクニックを用いて、1回目に呼び出されたときにオブジェクトを初期化し、2回目以降はすでに初期化されたオブジェクトを返すように実装しています。28行目で、ツリーに属する（ルートを除く）メッセージの配列を変数 messages にセットしています。select メソッドについてはChapter 6 で説明しました。メッセージツリーを作成・表示する際に必要となるのは id、 parent_id、 subject という3つのカラムだけなので、データベースへの負荷を減らすため、取得対象のカラムを絞り込んでいます
  attr_accessor :child_nodes

  def tree
    return @tree if @tree
    r = root || self
    messages = Message.where(root_id: r.id).select(:id, :parent_id, :subject)
    @tree = SimpleTree.new(r, messages)
  end

  # ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
  # * add_tagメソッドでは、引数labelをvalueカラムの値として持つTagオブジェクトの有無を調べ、なければ作り、そしてMessageオブジェクトと結び付けます。
  def add_tag(label)
    self.class.transaction do
      # ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロックを実行している
      # * トランザクションの冒頭で hash_locks テーブルのレコード1個に対する排他的ロックを取得している
      HashLock.acquire("tags", "value", label)
      # HashLock.acquire("tags", "value", label)
      tag = Tag.find_by(value: label)
      tag ||= Tag.create!(value: label)
      unless message_tag_links.where(tag_id: tag.id).exists?
        message_tag_links.create!(tag_id: tag.id)
      end
    end
  end

  # ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
  # * remove_tagメソッドでは、引数labelをvalueカラムの値として持つTagオブジェクトの有無を調べ、あればMessageオブジェクトとの結びつきを絶ちます。
  # * さらに、その結果としてそのTagオブジェクトがどのMessageオブジェクトとも結び付けられていない状態になれば、Tagオブジェクトを削除します。tagsテーブルへの操作とmessage_tag_linksテーブルへの操作は、どちらかだけが成功してはまずいので、メソッド全体をトランザクションで囲んでいます。
  #  ^ HashLockをいつ利用すべきか 　この節で検討したような種類のレースコンディションは、次の2つの条件が重なると常に発生します。あるテーブルのカラムに一意制約が設定されている。そのカラムの値をユーザーが自由に選択できる。　例えば、あなたがソーシャルネットワークサービス（SNS）またはそれに類似したWebアプリケーションを開発しており、そのユーザーは登録時にユーザーを識別するための名前（仮にスクリーンネームと呼びます）を自由に設定できるとします。おそらくは users テーブルに screen_name というカラムを作るでしょう。このカラムはユーザーを識別するためのものですので、当然ながら一意制約を課します。この結果、レースコンディションの発生条件が整うことになります
  def remove_tag(label)
    self.class.transaction do
      # ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロックを実行している
      # * トランザクションの冒頭で hash_locks テーブルのレコード1個に対する排他的ロックを取得している
      # - 職員AがXというタグを削除しようとしている瞬間に、別の職員BがXというタグを追加しようとすると、元の実装ではレースコンディションが発生する可能性があります。
      Hashlock.acquire("tags", "value", label)
      if tag = Tag.find_by(value: label)
        message_tag_links.find_by(tag_id: tag.id).destroy
        if tag.message_tag_links.empty?
          tag.destroy
        end
      end
    end
  end
end




# - 説明:
# ! my question is, root and parent are in the same table but why you can do like parent.customer or parent.root?

# Railsでは、belongs_to、has_one、has_many、およびその他の同様のメソッドで定義されるリレーションシップは、データベースのテーブル同士をリンクする仕組み以上のものを提供します。関連するオブジェクトを、あたかも現在のオブジェクトのプロパティであるかのようにアクセスできるメソッドを作成するのです。これはRailsのActiveRecord ORM（Object-Relational Mapping）マジックの重要な側面です。

# これを、今示したMessageクラスについて分解してみましょう：

# - 1. belongs_to :parent, class_name: "Message", foreign_key： 「parent_id", optional: true: この関連付けは、Message が親を持つことができることを意味します。
# - つまり、Messageインスタンス(仮にmessage_instanceとします)があって、message_instance.parentを使うと、message_instanceを親として関連する別のMessageインスタンスを取得することになります。

# - parentは単なる別のMessageであり、Messageはcustomerとbelongs_toの関係にあり、ルートを持つことができるので、メソッドを連鎖させることができます。つまり、parent.customer は親メッセージに関連付けられた Customer インスタンスをフェッチします。同様に、parent.root は親メッセージのルート Message インスタンスをフェッチします。

# ¥ 以下に例を示します：
# 会話スレッドがあるとします：

# ¥ Message1 -> (replied by) -> Message2 -> (replied by) -> Message3 という会話スレッドがあるとします。
# ¥ Message3があなたのmessage_instanceだとします：

# * message_instance.parentはMessage2を返す。
# * message_instance.parent.customerは、Message2を作成した顧客を提供します。
# * message_instance.parent.rootはスレッドのルート、つまりMessage1を返します。
# * このようにメソッドを連鎖させる機能は、RailsのActiveRecordが提供する便利で表現力豊かな機能で、データベースから関連データを取得するSQLクエリを抽象化します。