class Phone < ApplicationRecord
  include StringNormalizer

  belongs_to :customer, optional: true
  belongs_to :address, optional: true

  before_validation do
    self.number = normalize_as_phone_number(number)
    # - 数字以外の文字をすべて除去する正規表現
    self.number_for_index = number.gsub(/\D/, "") if number
  end

  # ¥ before_create ブロックには、このオブジェクトがデータベースに初めて保存される直前に実行されるべき処理を記述します。ここでは、このオブジェクトが Address オブジェクトと関連付けられている場合に、 Customer オブジェクトとの関連付けを行っています。
  before_create do
    self.customer = address.customer if address
  end

  # - 形式チェックに使用している正規表現は、先頭にプラス記号（+）が0個または1個あり、1個以上の数字が並び、「マイナス記号（-）1個と1個以上の数字」という組み合わせが0個以上並んで末尾に至る、という文字列に対するものです。「090-1234-5678」や「+81-3-1234-5678」や「110」などに合致します。
  validates :number, presence: true,
    format:  { with: /\A\+?\d+(-\d+)*\z/, allow_blank: true }
end


# - 20230816 self.customer = address.customer if addressの説明
# before_create do
#   self.customer = address.customer if address
# end

# このコードブロックはbefore_createコールバックで、新しいレコードが初めてデータベースに保存される直前に実行されます。

# before_createです： これはRails Active Recordのコールバックです。コールバックとは、オブジェクトのライフサイクルの特定のタイミングで呼び出されるメソッドのことです。この場合、before_createは新しいレコードがデータベースに作成される直前に呼び出されます。

# self.customer = address.customer if address.createが呼び出されます： これがコールバック内の実際のロジックです。

# if addressを呼び出します： これは、Phoneオブジェクトに関連するアドレスレコードがあるかどうかをチェックします。addressがnilまたは存在しない場合、割り当て操作（self.customer = address.customer）は実行されません。

# self.customer = address.customer： Phoneオブジェクトに関連付けられたアドレスがある場合、そのアドレスに関連付けられた顧客は、Phoneオブジェクトのcustomer属性に割り当てられます。

# 簡単に言うと、このコールバックは、新しいPhoneレコードが作成され、それが関連付けられたアドレスを持っている場合、そのアドレスの顧客にも関連付けられます。これは、電話がアドレスに直接関連する可能性があり、そのアドレスを所有する顧客と直接関連づけたい場合に便利です。