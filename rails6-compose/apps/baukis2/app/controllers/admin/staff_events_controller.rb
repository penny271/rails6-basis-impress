# class Admin::StaffEventsController < ApplicationController
class Admin::StaffEventsController < Admin::Base
  def index
    if params[:staff_member_id]
      @staff_member = StaffMember.find(params[:staff_member_id])
      # @events = @staff_member.events.order(occurred_at: :desc)
      @events = @staff_member.events
    else
      # @events = StaffEvent.order(occurred_at: :desc)
      # ¥ events=StaffEventを代入すると、StaffEventモデルそのものが@eventsに代入されます。これはActiveRecordリレーションオブジェクトで、.whereや.orderなどのActiveRecordクエリメソッドを呼び出すことができます。eventsを繰り返し処理するか、明示的に.allを呼び出すまでは、実際にデータベースにアクセスしてすべてのStaffEventレコードを取得することはありません。
      #- そのため、@events = StaffEventを使用すると、最終的なクエリを実行する前に、より多くの条件を柔軟に追加できます。
      @events = StaffEvent
    end

    # @events = @events.order(occurred_at: :desc)

    # ¥ 20230806 ! N+1 問題を解決する  = クエリの数をできるだけ少なくする
    # - Relation オブジェクトの includes メソッドに対して関連付けの名前を与えると、実際のクエリの直後に関連付けられたモデルオブジェクトを一括して取得するクエリが発行されるようになります。その結果、クエリの回数は2回に減り、多くの場合パフォーマンスの向上につながります。
    # @events = @events.includes(:member)
    # ¥ 20230806 ページネーション用 https://tinyurl.com/22rfrhjv
    # - デフォルトの値が適用される baukis2/config/initializers/kaminari_config.rb
    # @events = @events.page(params[:page])  # 10件表示
    ## @events = @events.page(params[:page]).per(50) # 50件表示

    #- 下記のように上記のコメントアウトを連鎖的に呼びdすことができる
    @events =
    @events.order(occurred_at: :desc).includes(:member).page(params[:page])
  end
end

# ¥ 20230806 kaminari説明:
# ¥ 9行目で使用されている page メソッドは、Gemパッケージ kaminari が提供しているものです。このメソッドは、引数に指定された整数をページ番号と見なして、モデルオブジェクトのリストから取得する範囲を絞り込みます。 nil を指定した場合、ページ番号は1となります。 ところで、 index アクションから5行目と9行目だけを抜き出すと次のようになります。

# 一見すると、この部分では次のような処理が行われているように見えます。
# 1. 5行目で、ある職員（@staff_member）に関連付けられた MemberEvent オブジェクトの配列が occurred_at 属性を基準に降順にソートされてインスタンス変数@events にセットされる。

# 2. インスタンス変数@events（配列）から page パラメータの値に該当する要素が抽出されて作られた配列が再びインスタンス変数@events にセットされる。 しかし、実際に行われている処理はこれとは異なります。

# - まず5行目のインスタンス変数@events にセットされるのは配列ではありません。 ActiveRecord::Relation クラスの子孫クラスのインスタンスです。本書では、これを Relationオブジェクト と呼びます。このオブジェクトが作られた時点では、まだデータベースに対するクエリは実行されていません。クエリを実行するための諸条件を保持しているだけです。

# - 同様に9行目で page メソッドが行っているのは、配列から要素を抽出することではありません。 page メソッドはレシーバである Relation オブジェクトに新たな検索条件を加えます。そして、 page メソッドの戻り値はやはり Relation オブジェクトです。それが9行目の等号（=）の左辺にあるインスタンス変数@events にセットされるの



