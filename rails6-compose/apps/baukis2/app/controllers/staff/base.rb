class Staff::Base < ApplicationController
  private def current_staff_member
    if session[:staff_member_id]
      #¥ Rubyの||=演算子は、しばしば「or equals」演算子と呼ばれる。これは、ある変数が現在nilかfalseである場合にのみ、その変数をある値に設定するために使われます。 20230723
      @current_staff_member ||= StaffMember.find_by(id: session[:staff_member_id])
    end
  end

  helper_method :current_staff_member
end

#¥ 7.3.2　 current_staff_memberメソッドの定義 名前空間 staff に属するすべてのコントローラに current_staff_member という private メソッドを与えるため、 Staff::Base というクラスを定義します。 app/controllers/staff ディレクトリに新規ファイル base.rb を次のような内容で作成してください。

#¥ base.rb の9行目にある helper_method は引数に指定したシンボルと同名のメソッドをヘルパーメソッドとして登録するメソッドです。つまり、 current_staff_member というメソッドを app/helpers/application_helper.rb に定義するのと同じ効果が得られます。この結果、 current_staff_member メソッドをERBテンプレートの中でも利用することが可能となります。

# これらの変更を行った結果、 Staff::TopController の継承関係が次のように変わります。
# 変更前 …… Staff::TopController ← ApplicationController
# 変更後 …… Staff::TopController ← Staff::Base ← ApplicationController

#! 遅延初期化
# current_staff_member は、現在ログインしている StaffMember オブジェクトを返すメソッドです。このメソッドでは 遅延初期化 というテクニックを用いています。 current_staff_member メソッドが初めて呼ばれたとき、インスタンス変数@current_staff_member の中身は nil であるため、演算子 ||= の右辺が評価されて@current_staff_member にセットされます。そして、このメソッドが2回目以降に呼び出されたときは、@current_staff_member に nil でも false でもない値がセットされているので、演算子 ||= の右辺は評価されずに、そのまま@current_staff_member の値が返されます。

# このようにすることで、 StaffMember.find_by メソッドが多くても1回しか呼ばれないようにしています。これを遅延初期化と呼びます。 3行目で使われている session は セッションオブジェクト を返すメソッドです。セッションオブジェクトはRailsアプリケーションがクライアントごとに保持するデータで、普通のハッシュ同様に読み書きできます。このオブジェクトに:staff_member_id というキーがあれば、その値を用いて StaffMember を検索して@current_staff_member にセットします。