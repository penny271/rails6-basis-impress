# ¥ 2.ch.12.3.2 タグ付け - 一意制約と排他的ロック
common_table_names = %w(hash_locks)
common_table_names.each do |table_name|
  path = Rails.root.join("db", "seeds", "#{table_name}.rb")
  if File.exist?(path)
    puts "Creating #{table_name}...."
    require(path)
  end
end

table_names = %w(
  staff_members administrators staff_events customers
  programs entries messages tags
)

table_names.each do |table_name|
  path = Rails.root.join("db", "seeds", Rails.env, "#{table_name}.rb")
  if File.exist?(path)
    puts "Creating #{table_name}...."
    require(path)
  end
end

# ¥ require(path)で該当のpathの中のファイルを読み、実行している!! 20230723