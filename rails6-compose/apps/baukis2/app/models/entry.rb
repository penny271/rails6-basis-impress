# 2.ch6.1.3
# 外部キー program_id を通じて Program モデルを参照し、外部キー customer_id を通じて Customer モデルを参照しています

class Entry < ApplicationRecord
  belongs_to :program
  belongs_to :customer
end
