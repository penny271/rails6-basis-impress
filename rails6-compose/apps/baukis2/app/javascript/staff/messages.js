// ¥ 2.ch.10.2.4 問い合わせ到着の通知 ajax
function update_number_of_unprocessed_messages() {
  const elem = $("#number-of-unprocessed-messages");
  $.get(elem.data("path"), (data) => {
    if (data == "0") elem.text("");
    else elem.text("(" + data + ")");
  }).fail(() => (window.location.href = "/"));
}

// $(document).on メソッドの第1引数に "turbolinks:load" が指定されています。この違いはとても重要です。 Baukis2では、Turbolinks（画面遷移を高速化させるライブラリ）という仕組みが有効であるため、Baukis2の職員用サイト内でリンクをクリックして画面遷移しても、ページ全体のリロードは発生しません。その際、 turbolinks:load というイベントが発生します。 もし messages.js において、 $(document).on メソッドの第1引数に "turbolinks:load" を指定すると、画面遷移のたびに window.setInterval メソッドが呼ばれます。このメソッドの効果はページ全体のリロードが発生するまで有効なので、1分おきに新規問い合わせ件数を調べる処理が多重に登録されてしまうことになります。つまり、画面遷移を繰り返すと、1分未満の間隔で頻繁にAjax呼び出しが行われてしまうのです。
// - $(document).ready メソッドを使用した場合、ブラウザのアドレスバーにURLを入力したり、ブラウザをリロードしたりして、ページ全体が読み込まれた直後にしか window.setInterval メソッドが呼ばれません。 このような仕組みにより、職員ページのヘッダに表示される新規問い合わせ件数は1分おきに自動的に更新されます
$(document).ready(() => {
  if ($("#number-of-unprocessed-messages").length)
    window.setInterval(update_number_of_unprocessed_messages, 1000 * 60);
});

// $.get はjQueryのメソッドです。この部分は、次のパターンに従っています。

// $.get(X, (data) => { Y }).fail(Z)

// X がAjaxでアクセスするAPIのURL、 Y がアクセスの結果を受けて実行するコードを示します。引数 data にはAPIから戻ってくるデータが格納されており、 Y の中でその値を参照できます。また、.fail(Z) を指定すると、Ajaxによるアクセスが失敗したときに Z が実行されます。 新規問い合わせの件数を表示するための span 要素の id 属性には "number-of-unprocessed-messages" という値が設定されています。その事実を利用して、この span 要素を変数 elem にセットしています。 この span 要素の data - path 属性には、新規問い合わせ件数を調べるAPIのURLパスがセットされています。

// data - で始まる名前を持つ属性の値は、jQueryの data メソッドで取得できます。 このURLパスに対してjQueryの $.get メソッドを用いてAjax呼び出しを行います。APIからのレスポンスは新規問い合わせ件数を表す文字列です。その値が "0" であれば span 要素の中身を空にし、そうでなければその値をカッコで囲んだ文字列で span 要素の中身を置き換えます。

// 一方で、職員が途中で利用停止になったり、アクセスが許可されるIPアドレスが変更されたり、セッションタイムアウトが発生する可能性もあります。その際は、 Staff::AjaxController で設定した before_action コールバックにより、サーバーからはステータスコード403が返却されます。

//* Javascript側ではステータスコード403を受け取ると「Ajaxによるアクセスが失敗した」と判断し、.fail() 以下のコードを実行してログインページへとリダイレクションをするようにしています
