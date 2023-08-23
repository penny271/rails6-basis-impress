class Staff::CustomerSearchForm
  include ActiveModel::Model
  include StringNormalizer # ¥ models/concernの中

  # ¥ 検索フォームの各フィールドに対応する属性を定義している
  attr_accessor :family_name_kana, :given_name_kana, :birth_year, :birth_month, :birth_mday, :address_type, :prefecture, :city, :phone_number, :gender, :postal_code, :last_four_digits_of_phone_number

  # ¥ 上記の属性に値が入ったものがフォームが submitされたときに返ってくる
  def search
    # - 2.ch3 20230819 値の正規化
    normalize_values

    rel = Customer

    if family_name_kana.present?
      rel = rel.where(family_name_kana: family_name_kana)
    end

    if given_name_kana.present?
      rel = rel.where(given_name_kana: given_name_kana)
    end

    rel = rel.where(birth_year: birth_year) if birth_year.present?
    rel = rel.where(birth_month: birth_month) if birth_month.present?
    rel = rel.where(birth_mday: birth_mday) if birth_mday.present?
    rel = rel.where(gender: gender) if gender.present?

    # ¥ address_type 属性には、空文字または"home" または"work" という文字列がセットされており、その値によって処理を切り替えています。 　 Relation オブジェクトの joins メソッドは、レコードの検索において テーブル結合 を行うためのメソッドです。簡単に言えば、他のテーブルのカラムの値に基づいてレコードを絞り込む、ということです。 joins メソッドの引数には、モデルのクラスメソッド has_many や has_one で定義された関連付けの名前を使用します。 joins メソッドも where メソッドや order メソッド同様に Relation オブジェクトを返します。 Customer モデルにはすでに :home_address と :work_address という関連付けが定義されています。未定義の関連付け :addresses については、このすぐ後で定義します。
    #^ .joins() レコードの検索において テーブル結合 を行うためのメソッド
    # address_typeが "work "の場合、relとwork_addressを結合する。その後、都道府県（または市区町村）によるフィルタリングがこの結合された結果セットに適用される。つまり、address_typeが "work "の場合、relはwork_addressが指定された都道府県と一致するレコードに対してフィルタリングされる。
    #- Railsでは、.joins()メソッドを使用して、指定したリレーションに対してINNER JOINを実行します。これは、両方のテーブルで一致する行のみが返されることを意味します。
    if prefecture.present? || city.present?
      case address_type
      when "home"
        rel = rel.joins(:home_address)
      when "work"
        rel = rel.joins(:work_address)
      when ""
        rel = rel.joins(:addresses)
      else
        raise
      end

      if prefecture.present?
        # ¥ 2.ch3 20230819 customer.rb にて   has_many :addressesすることで使用可能になる
        rel = rel.where("addresses.prefecture" => prefecture)
        # - 別の書き方: rel = rel.where(addresses: { prefecture: prefecture })
      end

      rel = rel.where("addresses.city" => city) if city.present?
    end

    if postal_code.present?
      case address_type
      when "home"
        rel = rel.joins(:home_address)
      when "work"
        rel = rel.joins(:work_address)
      when ""
        rel = rel.joins(:addresses)
      else
        raise
      end

      rel = rel.where("addresses.postal_code" => postal_code)
    end

    if phone_number.present?
      rel = rel.joins(:phones).where("phones.number_for_index" => phone_number)
    end

    if last_four_digits_of_phone_number.present?
      rel = rel.joins(:phones)
        .where("RIGHT(phones.number_for_index, 4) = ?",
          last_four_digits_of_phone_number)
    end

    rel = rel.distinct
    # rel = rel.uniq # - 上記と同じ別の書き方

    rel.order(:family_name_kana, :given_name_kana)

  end # end of def search

  private def normalize_values
    self.family_name_kana = normalize_as_furigana(family_name_kana)
    self.given_name_kana = normalize_as_furigana(given_name_kana)
    self.city = normalize_as_name(city)
    # - 電話番号に関しては、全角英数字を半角に変換した後で、数字以外の文字（正規表現は \D）をすべて除去するという処理をしています。
    # 例えば、normalize_as_phone_numberメソッドが単に入力を返すだけで、入力が "123-456-7890 "であれば、結果は "1234567890 "となる。入力がnilの場合、結果もnilになります。
    self.phone_number = normalize_as_phone_number(phone_number)
      .try(:gsub, /\D/, "")
    #! 下記でも問題なかった 20230819
    # ! self.phone_number = normalize_as_phone_number(phone_number).gsub(/\D/, "")
    self.postal_code = normalize_as_postal_code(postal_code)
    # self.last_four_digits_of_phone_number =
    #   normalize_as_phone_number(last_four_digits_of_phone_number)
  end
end