Rails.application.configure do
  config.action_view.form_with_generates_remote_forms = false
end

# ¥ 本書ではリモートフォームを使わないので、 form_with メソッドが普通のフォームを作るように設定を変更しましょう。 config/initializers ディレクトリに新規ファイル action_view.rb を次の内容で作成