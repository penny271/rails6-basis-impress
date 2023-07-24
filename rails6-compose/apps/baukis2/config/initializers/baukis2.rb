Rails.application.configure do
  config.baukis2 = {
    staff: { host: "baukis2.example.com", path: "" },
    admin: { host: "baukis2.example.com", path: "admin" },
    customer: { host: "example.com", path: "mypage" }
  }
end


# ¥ 2行目の config は、 Rails::Application::Configuration クラスのインスタンスを返すメソッドです。このオブジェクトはRails自体あるいはアプリケーションに組み込まれたGemパッケージの各種設定を保持しているのですが、実は設定項目を自由に追加できます。ここでは baukis2 という項目を追加し、それにハッシュをセットしています。

# このハッシュには:staff、:admin、:customer という3つのキーがあります。そして、それらのキーに対する値が、利用者別トップページの設定を表しています。 Railsアプリケーションの中では次の式でこのハッシュにアクセスできます。

# ¥ Rails.application.config.baukis2

# すなわち、職員トップページのホスト名（ baukis2.example.com）を参照したければ、次のように書けばいいわけです。

# ¥ Rails.application.config.baukis2[:staff][:host]

