# class CreatePhones < ActiveRecord::Migration[6.0]
#   def change
#     create_table :phones do |t|

#       t.timestamps
#     end
#   end
# end

class CreatePhones < ActiveRecord::Migration[6.0]
  def change
    create_table :phones do |t|
      t.references :customer, null: false
      t.references :address
      t.string :number, null: false # 電話番号
      t.string :number_for_index, null: false # 検索用電話番号
      t.boolean :primary, null: false, default: false # 優先フラグ

      t.timestamps
    end

    add_index :phones, :number_for_index
    add_foreign_key :phones, :customers
    add_foreign_key :phones, :addresses
  end
end

# 20230814
# - customers テーブルと addresses テーブルとの間で関連付けが行われます。ただし、個人電話番号は addresses テーブルと関連付けされないので、 address_id カラムにはNULL制約を課していません。 number_for_index カラムには、電話番号から数字以外の文字（+ と-）を除去した文字列がセットされます。