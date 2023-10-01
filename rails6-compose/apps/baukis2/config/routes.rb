Rails.application.routes.draw do
  config = Rails.application.config.baukis2
  # ¥ 下記は実験 コメントアウト 名前空間なし ver.
  # root "temporary#index"

  # puts("config[:admin][:host]:: #{config[:admin][:host]}")
  # puts("config[:staff][:host]:: #{config[:staff][:host]}")
  # puts("config[:staff][:path]:: #{config[:staff][:path]}")
  puts(Rails.application.config.hosts)

  # constraints host: "example.com" do
  #   get "login" => "staff/sessions#new", as: :login
  # end

  # get "login" => "staff/sessions#new", as: :login

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
      # resource :account, except: [ :new, :create, :destroy]
      # ¥ 2.ch.9 章末問題
      resource :account, except: [ :new, :create, :destroy ] do
        patch :confirm
      end
      resource :password, only: [ :show, :edit, :update] # 20230809
      resources :customers
      # resources :programs
      # ¥ 2.ch.7.3.2
      # - programs リソースを定義する resources メソッドにブロックを加え、ブロックの中でリソース entries を定義しています。本編Chapter 13で解説した「ネストされたリソース」です。ただし、リソース entries を定義する resources メソッドの only オプションに空の配列が渡されているため、基本の7アクションは設定されません。その代わりに、PATCHでアクセスするための update_all アクションが設定されています。 この update_all アクションは、単独の Entry オブジェクトを書き換えるものではなく、複数個の Entry オブジェクトを一括更新します。そのため、 on オプションに :collection が指定されています。つまり、 update_all アクションには対象オブジェクトを特定するためのパラメータ "id" が渡りません。
      resources :programs do
        resources :entries, only: [] do
          patch :update_all, on: :collection
        end
      end
      # ¥ 2.ch.10.2.1 問い合わせ到着の通知
      # messages/count というパスへのアクセスを Staff::AjaxController コントローラに振り向けています。このコントローラ名は、Railsの標準的な命名法から外れています。このコントローラはAjaxリクエスト専用のアクションが集められる特別なものなので、特別な名前を与えることにしました
      get "messages/count" => "ajax#message_count"
      # ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
      # * POSTメソッドとDELETEメソッドの両方に対応したアクションのためのルーティングを定義しています。タグの追加・削除は後ほどAjaxにより実装するので、コントローラにはStaff::AjaxControllerを指定しています。また、問い合わせのデータベースレコードを特定できるようにURLパターンに:idを含めている点にも注意をしてください。
      post "messages/:id/tag" => "ajax#add_tag", as: :tag_message
      delete "messages/:id/tag" => "ajax#remove_tag"

      # ¥ 2.ch.11.1.1 ツリー構造
      #- inbound、 outbound、 deleted は、それぞれ「問い合わせ一覧」、「送信一覧」、「ゴミ箱」を表示するためのアクションです。いずれの場合も複数のデータベースレコードへのアクセスが発生するため、コレクションルーティングとして設定しています
      # * これらはコレクションルートなので、メンバールートのように:idパラメータを必要としません。
      resources :messages, only: [ :index, :show, :destroy ] do
        get :inbound, :outbound, :deleted, on: :collection

        # ¥ 2.ch.12.1.1 タグ付け
        resource :reply, only: [ :new, :create] do
          post :confirm
        end
      end
      # ¥ 2.ch.12.3.2 タグ付け
      # staff/tagsリソースにネストされたmessagesリソースを定義しています。コントローラは既存のstaff/messagesを利用します。
      resources :tags, only: [] do
        resources :messages, only: [ :index ] do
          get :inbound, :outbound, :deleted, on: :collection
        end
      end
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
      # ! 20230805 :staff_members が コントロール名となる
      # ! 20230805 railsが自動で ルート名を作成する rails routes で確認できる
      # resources :staff_members
      # ¥ 20230806 ネストされたリソース
      #  - ルーティング結果:
      # - admin_staff_member_staff_events GET    /admin/staff_members/:staff_member_id/staff_events(.:format)    admin/staff_events#index {:host=>"baukis2.example.com"}
      resources :staff_members do
        resources :staff_events, only: [:index]
      end
      resources :staff_events, only: [:index]
      # ¥ 2.ch5.2.2 許可IPアドレスの管理
      # - on: :collection： このルートがコレクションルートであることを指定します。コレクションルートはリソースのコレクション（この場合は allowed_sources）に作用します。単一のリソースに作用しないため、ルートはIDを必要としません。生成されるURLは/allowed_sources/deleteになります。
      resources :allowed_sources, only: [:index, :create] do
        delete :delete, on: :collection
      end

      # -ルーティング結果: GET /admin/staff_events  | ルーティング名: :admin_staff_events
    end # end of namespace
  end

  # baukis2/config/initializers/baukis2.rb  ->  customer: { host: "example.com", path: "mypage" }
  constraints host: config[:customer][:host] do
    namespace  :customer, path: config[:customer][:path] do
      root "top#index"
      get "login" => "sessions#new", as: :login
      resource :session, only: [:create, :destroy]
      # ¥ 2.ch.9.1.1 顧客自身によるアカウント管理機能
      # resource :account, except: [ :new, :create, :destroy]
      # ¥ 2.ch.9.2.1 顧客自身によるアカウント管理機能
      resource :account, except: [ :new, :create, :destroy] do
        # * confirm アクションを追加(PATCHメソッドでアクセス)
        patch :confirm
      end

      # ¥ 2.ch.8.1.1 プログラム一覧表示・詳細表示機能(顧客向け)
      # resources :programs, only: [ :index, :show]
      # ¥ 2.ch.8.2.2 プログラム一覧表示・詳細表示機能(顧客向け)
      resources :programs, only: [ :index, :show] do
        # - リソース programs にネストされた単数リソース entry を定義しています。顧客とプログラムが特定された文脈において、それらと関連付けられた Entry オブジェクトは0個または1個しか存在しないので、 id パラメータなしで取得できます。そのため単数リソースとして定義します。
        resource :entry, only: [ :create ] do
          patch :cancel
          # - 上記の httpメソッドとurlパスのパターン
          # create - POST /customer/programs/:program_id/entry
          # cancel - PATCH /customer/programs/:program_id/entry/cancel
        end
      end
      # ¥ 2.ch.10.1.5 Ajax 顧客向け問い合わせフォーム
      # - confirm という3つのアクションを追加します。顧客アカウント編集用の確認画面を実装した9-2-1項「ルーティング」では、既にデータベース上に存在するレコードを書き換える処理だったため、確認用のアクション confirm をPATCHメソッドで呼ぶことにしました。一方、今回は新しいレコードを追加する処理のため、 confirm アクションをPOSTメソッドで呼んでいます。また、 confirm アクションは resources メソッドにネストされているため、コレクションルーティング（本編9-2-2「ルーティングの分類」参照）として指定をする必要があります。なぜなら、この指定をしない場合のURLパスは/mypage/messages/:message_id/confirm となり、不必要なパラメータ message_id が含まれてしまうからです
      # resources :messages, only: [ :new, :create] do
      # ¥ 2.ch.12.5演習問題
      # resources :messages, only: [ :index, :show, :new, :create] do
      # ¥ 2.ch.12.5演習問題 3
      resources :messages, except: [ :edit, :update] do
        post :confirm, on: :collection
        resource :reply, only: [ :new, :create] do
          post :confirm
        end
      end
    end
  end
end

# ¥ 4行目と5行目の末尾にある as オプションは、ルーティングに名前を付けるためのものです。こうしておけば、ERBテンプレートの中で:staff_login や:staff_session というシンボルを用いてURLパスを参照できるようになります。Baukis2では、設定ファイルによってURLパスが変化しますので、ルーティングへの名前付けは必須

