# ¥ 2.ch.12.2.1 タグ付け
# class CreateTags < ActiveRecord::Migration[6.0]
#   def change
#     create_table :tags do |t|

#       t.timestamps
#     end
#   end
# end

# ÷

class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :value, null: false

      t.timestamps
    end

    add_index :tags, :value, unique: true
  end
end