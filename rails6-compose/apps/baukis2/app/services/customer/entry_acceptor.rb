# ¥ 2.ch.8.2.3 プログラム一覧表示・詳細表示機能(顧客向け)
class Customer::EntryAcceptor
  def initialize(customer)
    @customer = customer
  end

  def accept(program)
    # ¥ 2.ch.8.4.2
    # * 申し込み開始日時を迎えていないプログラムは顧客には存在自体が見えないので、そのようなプログラムへの申し込みが行われることは論理的にありえません。しかし、将来Baukis2に加えられる変更（バグ）によって、申し込み開始前のプログラムが顧客に見えてしまう可能性はありますので、その芽を摘んでおきましょう
    # ! 論理的にありえない自体なので例外を発生させている
    raise if Time.current < program.application_start_date
    # ¥ 2.ch.8.4
    # * 申し込み終了日時を過ぎたプログラムに関しては、プログラム詳細ページに無効化された「募集終了」ボタンが表示されるため、普通は申し込めません。しかし、申し込み終了日時間際のプログラムでは、顧客が詳細ページを開いた瞬間からボタンを押す瞬間の間に期限が切れる可能性があります。その場合、申し込みを拒否しなければなりません
    return :closed if Time.current >= program.application_end_time
    # if max = program.max_number_of_participants
    #   if program.entries.where(canceled: false).count < max
    #     program.entries.create!(customer: @customer)
    #     return :accepted
    #   else
    #     return :full
    #   end
    # else
    #   program.entries.create!(customer: @customer)
    #   return :accepted
    # end
    # ¥ 2.ch.8.3.2 排他的ロック プログラム一覧表示・詳細表示機能(顧客向け)
    ActiveRecord::Base.transaction do
      # - モデルオブジェクトのインスタンスメソッド lock! は、そのオブジェクトが指すテーブルレコードに対して排他的ロックを取得します。なお、排他的ロックをするにはすでにトランザクションが開始されている必要があります。 いまあるセッションAがトランザクションを開始し、あるテーブルXの特定のレコードRに対する排他的ロックを取得したとします。 以後、「セッション（session）」という言葉を、データベース管理システム（DBMS）への「接続（connection）」とほぼ同義で使用します。Rails用語のセッション（ユーザーのログイン状態を示す概念）とは意味が異なりますので、注意してください。 すると、セッションAがトランザクションを終了するまで、他のセッションはRに対する排他的ロックを取得できません。 つまり、顧客AとBがほぼ同時にあるプログラムへの申し込みを行い、顧客Aのための処理で EntryAcceptor#accept メソッドが一瞬早く呼び出された場合、顧客Bのための処理は program.lock! のところで待たされます。顧客Aの申し込みが受理されるまで、顧客Bのための処理は program.lock! から先に進めません。これで、レースコンディションは解決です。
      program.lock!
      # ¥ 2.ch.8.4.3 二重申込みのチェック
      # if max = program.max_number_of_participants
      if program.entries.where(customer_id: @customer.id).exist?
        return :accepted
      elsif max = program.max_number_of_participants
        if program.entries.where(canceled: false).count < max
          program.entries.create!(customer: @customer)
          return :accepted
        else
          return :full
        end
      else
        program.entries.create!(customer: @customer)
        return :accepted
      end
    end
  end
end

# -2.ch.8.3.2 排他的ロック: 実運用環境におけるRailsアプリケーションはマルチプロセスあるいはマルチスレッドで動作しており、複数のアクションが並列で実行されるからです。 この場合、想定外のことが発生します。②で顧客Bが申し込めるかどうかをチェックした段階では、まだ1件分余裕があるので、顧客Bの申し込みは拒否されません。そして、③と④で順に顧客Aと顧客Bからの申し込みが受理されます。その結果、申込数が1件超過してしまうのです。 こういうことは滅多に起きないように思われるかもしれませんが、そうとも限りません。何かのきっかけで申し込みが殺到すれば容易に発生します。また、滅多に起きないバグは発見されにくいため、かえって厄介であるとも言えます。 上記のように、並列で走る複数の処理の結果が、順序やタイミングによって想定外の結果をもたらすことをレースコンディション（race condition）と呼びます。

