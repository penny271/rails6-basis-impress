Rails.application.routes.draw do
  config = Rails.application.config.baukis2
  # ¥ 下記は実験 コメントアウト 名前空間なし ver.
  # root "temporary#index"

  # namespace  :staff do
  # ¥ /staff/login から /login に変わる path ""でurlのpathを変えたため 20230724
  # ¥ ホスト名によるルーティング制限 20230725
  # constraints host: "baukis2.example.com" do
  constraints host: config[:staff][:host] do
    # namespace :staff, path: "" do
    namespace :staff, path: config[:staff][:path] do
      root "top#index"
      get "login" => "sessions#new", as: :login
      # post "sessions" => "sessions#create", as: :session
      # delete "sessions" => "sessions#destroy"
      #¥ 上記をresourceで書き換えることが可能! 20230724
      resource :session, only: [ :create, :destroy]

      # ¥ 単数リソース 自分自身の情報を変更したり参照したりする 20230724
      #  ! コントローラ名はstaff/accounts(複数形)になる!!
      resource :account, except: [ :new, :create, :destroy]
    end
  end

  constraints host: config[:admin][:host] do
    #  namespaceで :admin となっているため path: を設定しなくてもurlに /admin はつく
    namespace  :admin, path: config[:admin][:path] do
      root "top#index"
      get "login" => "sessions#new", as: :login
      # post "sessions" => "sessions#create", as: :session
      # delete "sessions" => "sessions#destroy"
      #¥ 上記をresourceで書き換えることが可能! 20230724
      resource :session, only: [ :create, :destroy]

      # get "staff_members" => "staff_members#index" # リスト表示
      # get "staff_members/:id" => "staff_members#show" # 詳細表示
      # get "staff_members/new" => "staff_members#new" # 登録フォームの作成
      # get "staff_members/:id/edit" => "staff_members#edit" # 編集フォームの表示
      # post "staff_members" => "staff_members#create" # 職員の追加
      # patch "staff_members/:id" => "staff_members#update" # 職員の更新
      # delete "staff_members/:id" => "staff_members#destroy" # 職員の削除

      # ¥ 上記を1行で書ける
      resources :staff_members
    end # end of namespace
  end

  constraints host: config[:customer][:host] do
    namespace  :customer, path: config[:customer][:path] do
      root "top#index"
    end
  end

end

# ¥ 4行目と5行目の末尾にある as オプションは、ルーティングに名前を付けるためのものです。こうしておけば、ERBテンプレートの中で:staff_login や:staff_session というシンボルを用いてURLパスを参照できるようになります。Baukis2では、設定ファイルによってURLパスが変化しますので、ルーティングへの名前付けは必須

