#¥ 16.3.1　 フォームオブジェクトの作成 フォームオブジェクトについてはChapter 8とChapter 14で学習しました。今回作るフォームオブジェクト Staff::CustomerForm は、3つのモデルオブジェクトを扱います。すなわち Customer オブジェクト、 HomeAddress オブジェクト、 WorkAddress オブジェクトです。ただし、フォームオブジェクトが属性として所持するのは Customer オブジェクトです。残りの2つのオブジェクトは、 Customer オブジェクト経由で間接的に所持することになります。 20230813
class Staff::CustomerForm
  include ActiveModel::Model

  # - persisted? メソッドは、モデルオブジェクトがデータベースに保存されているかどうかを真偽値で返します。非Active Recordモデルの persisted? メソッドはデフォルトで false を返すのですが、ここではクラスメソッド delegate を用いて persisted? メソッドをオーバーライド（上書き）しているわけです。 なぜ、このオーバーライドが必要なのでしょうか。実は、ヘルパーメソッド form_with がフォーム送信時に使用するHTTPメソッドを決定する際に、対象オブジェクトの persisted? メソッドを呼んでいるのです。その戻り値が真であればHTTPメソッドは PATCH に、偽であれば POST になります。すなわち、このオーバーライドをしないと、常に非ActiveRecordモデルのpersisted?メソッドが評価されるため、HTTPメソッドがPOSTに固定されてしまうのです。
  # attr_accessor :customer #¥ setter, getterを設定している
  # - 自宅住所を入力する 及び 勤務先を入力する という2つのチェックボックスの状態を表す属性を定義している
  attr_accessor :customer, :inputs_home_address, :inputs_work_address #¥ setter, getterを設定している

  # - 20230815 この行は、.persisted? と .save メソッドが @customer オブジェクトに委譲されていることを示しています。つまり、Staff::CustomerFormのインスタンスで.saveを呼び出すと、実際にはフォームがラップしている@customerオブジェクトで.saveが呼び出されるということです。
  # - つまり、.save メソッドは @customer オブジェクトから呼び出され、Customer クラスのインスタンスに見えます。Customerクラスが典型的なActive Recordモデル（Railsアプリケーションでは一般的な慣習です）である場合、.saveメソッドはActiveRecord::Baseから継承されます。
  delegate :persisted?, :save, to: :customer
  # ¥ deletegateのおかげで、persisted? が呼び出されると customer.persisted? が評価される

  def initialize(customer = nil)
    @customer = customer
    # - class Customer < ApplicationRecord なので下記で gender属性に "male"をセットすることができる! 20230813
    #¥ そうです。Customerクラスのインスタンスを性別などの属性で初期化できるのは、CustomerがApplicationRecordを継承しているからです。ApplicationRecordはActiveRecord::Baseを継承しており、ActiveRecord::Baseはデータベースのレコードを作成、読み込み、更新、削除するための豊富なAPIやその他の高度な機能を提供しています。その機能のひとつが、ハッシュを使って属性を持つオブジェクトを初期化する機能だ。
    #¥ つまりこの文脈では、Staff::CustomerFormが既存の顧客なしで初期化された場合、gender属性が "male "に設定された新しい顧客オブジェクトが作成されるようにしています。

    #- 20230814 ActiveRecordでは、.buildメソッドを使用して関連付けられたモデルの新しいインスタンスを作成します。この新しいインスタンスは自動的に親に関連付けられますが、データベースには保存されません。これは、関連レコードをすぐに永続化せずに設定したい場合に便利です。
    @customer ||= Customer.new(gender: "male")
    # - クラス内のインスタンス・メソッドのコンテキストでは、self はメソッドが呼び出されるクラスのインスタンスを指します。クラスの内部でインスタンス・メソッドの外部で使用される場合 (例えば、クラス・メソッドの内部やクラス・レベルの属性を定義する場合)、self はクラス自体を指します。
    #¥ Staff::CustomerForm クラスでは、キーワード self は Staff::CustomerForm の現在のインスタンスを参照するために使用されます。
    self.inputs_home_address = @customer.home_address.present?
    puts("aaaa-home_address: #{@customer.home_address&.type}")
    # ! 下記がないと _customer_fields.html.erb で p.objectが nil になり(p.object.personal_phones.each_with_index do |phone, index|)電話番号欄が表示されない 特に new.html.erb に表示させるとき 20230816
    # - いくつ空のオブジェクトを作るか設定している 最大2つまで
    (2 - @customer.personal_phones.size).times do
      @customer.personal_phones.build
    end

    self.inputs_work_address = @customer.work_address.present?
    #- 20230813 build_home_address は、クラスメソッド has_one によって Customer モデルに追加されたインスタンスメソッドで、初期状態の HomeAddress オブジェクトをインスタンス化して自分自身と結び付けます。この段階では HomeAddress オブジェクトはデータベースに保存されません。このオブジェクトはフォームを表示するために利用されます
    @customer.build_home_address unless @customer.home_address
    @customer.build_work_address unless @customer.work_address
    (2 - @customer.home_address.phones.size).times do
      @customer.home_address.phones.build
    end
    (2 - @customer.work_address.phones.size).times do
      @customer.work_address.phones.build
    end
  end

  #  ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥ 20230813 update処理 ¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥¥
  #¥ params[:form] が返すのは、:customer、:home_address、:work_address という3つのキーを持つハッシュです。そのハッシュを h とすれば、 h[:customer] は基本情報セクションの各フィールドに入力された値を含むハッシュを返します。同様に、 h[:home_address] は自宅住所セクションの、 h[:work_address] は勤務先セクションの各フィールドに入力された値を含むハッシュを返すことになります。
  # ! customers_controller.rb が @customer_form.assign_attributes(params[:form]) と呼び出しているため、@params = params = params[:form] となり、下記の結果を得ることができる!!
  def assign_attributes(params = {})
    @params = params
    puts("★params::::: #{params}")
    #- customers_controller.rb が @customer_form.assign_attributes(params[:form]) と呼び出しているため、下記の結果を得ることができる!!
    # params ::::: {"customer"=>{"email"=>"aaa@example.com", "password"=>"aaa", "family_name"=>"aaa", "given_name"=>"bbb", "family_name_kana"=>"エエエ", "given_name_kana"=>"ビビビ", "birthday"=>"1990-11-24", "gender"=>"female"}, "inputs_home_address"=>"1", "home_address"=>{"postal_code"=>"1234567", "prefecture"=>"北海道", "city"=>"aaa", "address1"=>"ddd", "address2"=>""}, "inputs_work_address"=>"1", "work_address"=>{"company_name"=>"aaa", "division_name"=>"bbb", "postal_code"=>"", "prefecture"=>"北海道", "city"=>"", "address1"=>"", "address2"=>""}}

    # - param is missing or the value is empty: home_address エラーを防ぐ 20230814
    # ¥ つまり、代入の場合は、セッター・メソッドを確実に呼び出すためにselfが必要になることが多い。値にアクセスする場合は、selfは不要。
    self.inputs_home_address = params[:inputs_home_address] == "1"
    self.inputs_work_address = params[:inputs_work_address] == "1"

    customer.assign_attributes(customer_params)
    # modelの クラスメソッド has_one によって下記のように書くことができる
    # customer.home_address.assign_attributes(home_address_params)
    # customer.work_address.assign_attributes(work_address_params)

    # - 20230815 .fetch(:phone)で引数に指定された引数の値を返す fetchの場合、キーが存在しない場合はエラーが発生する
    #^ フォームからの送信データを受けるコード
    phones = phone_params(:customer).fetch(:phones)
    # 取得される値の例:
    # {"0"=>{"number"=>"09012345678","primary"=>"1"},"1"=>{"number"=>"","primary"=>"0"}}

    customer.personal_phones.size.times do |index|
      attributes = phones[index.to_s]
      if attributes && attributes[:number].present?
        customer.personal_phones[index].assign_attributes(attributes)
      else
        customer.personal_phones[index].mark_for_destruction
      end
    end

    # - param is missing or the value is empty: home_address エラーを防ぐ 20230814
    # - 入力可能な場合にのみ
    if inputs_home_address
      customer.home_address.assign_attributes(home_address_params)
      phones = phone_params(:home_address).fetch(:phones)
      customer.home_address.phones.size.times do |index|
        attributes = phones[index.to_s]
        if attributes && attributes[:number].present?
          customer.home_address.phones[index].assign_attributes(attributes)
        else
          customer.home_address.phones[index].mark_for_destruction
        end
      end
    else
      # ¥ 関連付けをnilに設定することは、事実上、関連レコードがないことを意味します。関連レコードがない場合、そのバリデーションはトリガーされません。=> customerオブジェクトを保存するときに、HomeAddressバリデーションはトリガーされません。
      # customer.home_address = nil
      # ! disabledにしている要素のフォームのバリデーションをスキップする方法 + すでにDBにデータがある場合は削除 20230814
      # - 関連付けられたモデルオブジェクトに対して mark_for_destruction メソッドを呼び出すと、このオブジェクトには「削除対象」という“印”が付けられます。この印のついたモデルオブジェクトは、親（私たちのケースでは Customer オブジェクト）が保存される際に、自動的にデータベースから削除されます（データベースが未保存なら単にバリデーションと保存の処理がスキップされます）。 ただし、この印付けの仕組みがうまく作用するためには、クラスメソッド has_one の autosave オプションに true が指定されている必要があります。 クラスメソッドhas_manyにもautosaveオプションがあり、これにtrueを指定すれば「削除対象」の印付けが有効になります。
      # 親 (この例では Customer) のバリデーションは、子 (HomeAddress) が破棄するようにマークされていても、通常どおり実行されます。
      # 破棄するようマークされた子 (HomeAddress) のバリデーションは、親 (Customer) の保存処理中には実行されません。
      #- 20230815 customer.home_address = nil と違い、 objectをnilにするのではなく、存在させ続けるので object.errors.full_messages_for(name).each do |message| で objectがnil でエラーが発生しない + validationをスキップし、DBからその値を削除する or DBにない場合、saveしない
      customer.home_address.mark_for_destruction
    end

    if inputs_work_address
      customer.work_address.assign_attributes(work_address_params)
      phones = phone_params(:work_address).fetch(:phones)
      customer.work_address.phones.size.times do |index|
        attributes = phones[index.to_s]
        if attributes && attributes[:number].present?
          customer.work_address.phones[index].assign_attributes(attributes)
        else
          customer.work_address.phones[index].mark_for_destruction
        end
      end
    else
      # ! disabledにしている要素のフォームのバリデーションをスキップする方法 + すでにDBにデータがある場合は削除 20230814
      # - 関連付けられたモデルオブジェクトに対して mark_for_destruction メソッドを呼び出すと、このオブジェクトには「削除対象」という“印”が付けられます。この印のついたモデルオブジェクトは、親（私たちのケースでは Customer オブジェクト）が保存される際に、自動的にデータベースから削除されます（データベースが未保存なら単にバリデーションと保存の処理がスキップされます）。 ただし、この印付けの仕組みがうまく作用するためには、クラスメソッド has_one の autosave オプションに true が指定されている必要があります。 クラスメソッドhas_manyにもautosaveオプションがあり、これにtrueを指定すれば「削除対象」の印付けが有効になります。
      # customer.work_address = nil
      customer.work_address.mark_for_destruction
    end
  end

  # - 20230813 最初に3つのモデルオブジェクトを要素とする配列を作っています。この配列に対して map(&:valid?) という形のメソッド呼び出しを行うと、[ false, false, true ]のような3つの真偽値を含む配列を返します（ コラム 「Array#mapメソッド」 を参照）。これらの真偽値は、3つのモデルオブジェクトにおけるバリデーションの成否を示しています。そして、配列の all? メソッドは、配列の全要素が真である場合に真を返し、そうでない場合に偽を返します。つまり、改良版　　　　　　　　　　　の valid? メソッドでは、3つのモデルオブジェクトすべてで必ずバリデーションが行われるのです。
  #! これをしないと最初のvalidationだけして、残りのvalidationを行わないためこの処理が必要
  # ¥ models/customer.rbで   has_one :home_address, dependent: :destroy, autosave: trueすることで下記の設定が不要になる
  # def valid?
  #   # customer.valid? && customer.home_address.valid? && customer.work_address.valid?
  #   [customer, customer.home_address, customer.work_address].map(&:valid?).all?
  # end

  #!   delegate :persisted?, :save, to: :customer したため def save が不要
  #! @customer_form = Staff::CustomerForm.new(Customer.find(params[:id]))  @customer_form.save という形で直接呼び出せるようになるため 20230814
  # - 明示的にすべて保存する必要あり! transactionを通じて、データの整合性を保つ
  # def save
  #   # ¥ customer.valid?メソッドはRailsの組み込みメソッドで、モデルオブジェクト（この場合はcustomer）がモデルで定義されているすべてのバリデーション要件を満たしているかどうかを判定するために使用されます。すべてのバリデーションに合格した場合、このメソッドはtrueを返します。
  #   # ! MG Customer オブジェクトのバリデーションを実行しても、関連付けられたオブジェクトのバリデーションまでは自動的に行われないのです。
  #   # if customer.valid?
  #   # ¥ models/customer.rbで   has_one :home_address, dependent: :destroy, autosave: trueすることで下記の設定が不要になる => Customerオブジェクトを保存すれば同時にHomeAddress, WorkAddressオブジェクトも保存されるようになるため
  #   # if valid?
  #   #   ActiveRecord::Base.transaction do
  #   #     customer.save!
  #   #     customer.home_address.save!
  #   #     customer.work_address.save!
  #   #   end
  #   # end
  #   customer.save
  # end

  # ¥ マスアサインメント対策 - ストロングパラメータ 20230813
  private def customer_params
    # @params.require(:customer).permit(
    @params.require(:customer).except(:phones).permit(
      :email, :password,
      :family_name, :given_name, :family_name_kana, :given_name_kana,
      :birthday, :gender
    )
  end

  private def home_address_params
    @params.require(:home_address).except(:phones).permit(
      :postal_code, :prefecture, :city, :address1, :address2
    )
  end

  private def work_address_params
    @params.require(:work_address).except(:phones).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
      :company_name, :division_name
    )
  end

  private def phone_params(record_name)
    #  ¥ .slice(:phones) は、.require(record_name)が返すハッシュから:phonesキー（とそれに関連する値）だけを取得します。もし:phonesキーが存在しなければ、（requireと違って）エラーにはならず、単に無視されます。
    # - .slice(:phones)のあとの結果は、{phones: { ... }} なので、 permit(phones: [:number, :primary])とアクセスする必要がある ネストされているためこのように対応が必要 20230815
    @params.require(record_name).slice(:phones).permit(
      phones: [ :number, :primary]
    )
  end
end

# - 20230813 assign_attributes 説明
# 後述するように、 assign_attributes メソッドは次のように利用されます。
# @customer_form.assign_attributes(params[:form])
#¥ params[:form] が返すのは、:customer、:home_address、:work_address という3つのキーを持つハッシュです。そのハッシュを h とすれば、 h[:customer] は基本情報セクションの各フィールドに入力された値を含むハッシュを返します。同様に、 h[:home_address] は自宅住所セクションの、 h[:work_address] は勤務先セクションの各フィールドに入力された値を含むハッシュを返すことになります。 これらの点を踏まえて、 assign_attributes メソッドの中身をご覧ください。

# @params = customer.assign_attributes(customer_params)
# customer.home_address.assign_attributes(home_address_params)
# customer.work_address.assign_attributes(work_address_params)

# まずインスタンス変数@params に引数 params をセットしています。そして、 customer 属性の assign_attributes メソッドを呼び出して、フォームで入力された値を顧客の各属性にセットしています。ただしプライベートメソッド customer_params を呼び出すことにより、フォームで入力された値をStrong Parametersのフィルターに通しています。 同様に、 customer.home_address と customer.work_address についても、それぞれ assign_attributes メソッドを呼び出し、自宅住所と勤務先の各属性を変更しています。 この章の冒頭で書いたように、自宅住所と勤務先の入力はオプショナル（省略可能）ですが、現段階ではこの仕様を考慮していません。


