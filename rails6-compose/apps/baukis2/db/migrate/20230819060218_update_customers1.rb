# class UpdateCustomers1 < ActiveRecord::Migration[6.0]
#   def change
#   end
# end

class UpdateCustomers1 < ActiveRecord::Migration[6.0]
  def up
    execute(%q{
      UPDATE customers SET birth_year = EXTRACT(YEAR FROM birthday),
        birth_month = EXTRACT(MONTH FROM birthday),
        birth_mday = EXTRACT(DAY FROM birthday)
        WHERE birthday IS NOT NULL
    })
  end

  def down
    execute(%q{
      UPDATE customers SET birth_year = NULL,
      birth_month = NULL,
      birth_mday = NULL
    })
  end
end

# - up と down メソッド
# いいえ、rails db:migrateを実行すると、upメソッドだけが実行されます。

# Railsのマイグレーションでは
# ¥ upメソッドは、新しいバージョンにマイグレートするときの動作を定義します。
# ¥ downメソッドは、必要に応じてupメソッドで行った変更を元に戻す方法を定義します。
# 特定のマイグレーションを元に戻したい場合は、マイグレーションをロールバックするコマンドを実行します (例: rails db:rollback)。この場合、downメソッドが実行され、upメソッドによる変更が元に戻されます。

# マイグレーションは以前のバージョンにロールバックすることができ、downメソッドがなければRailsはupメソッドで行った変更を元に戻す方法がわからないため、変更を元に戻す方法を記述するdownメソッドが不可欠であることを覚えておいてください。

#- 2.ch3 20230819
# Rubyでは、%qは実際にシングルクォートを使わずにシングルクォートの文字列を定義する方法です。定義したい文字列に一重引用符や二重引用符が含まれている場合、それらをエスケープする必要がなくなるので、特に便利です。

# 以下が%qの仕組みである：

# q{...}は一重引用符で囲まれた文字列（'...'）と等価です。
# 開始 { と終了 } の間はすべて文字列の一部として扱われます。