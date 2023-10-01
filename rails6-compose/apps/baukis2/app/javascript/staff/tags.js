// ¥ 2.ch.12.2.3 タグ付け - Tag-it yarn不可だったため CDNで代替した
// * require関数はCommonJSモジュールシステムの一部であり、JavaScriptモジュールを整理して含める方法です。
// - Rails 6からWebpackerを通じてRailsに統合されたWebpackのようなツールの登場により、RailsのJavaScriptファイルでrequire関数を使用できるようになりました。

// * require("jquery-ui");はjQuery UIライブラリを含んでいます。これは、jQuery JavaScript Libraryの上に構築されたユーザーインターフェイスのインタラクション、エフェクト、ウィジェット、テーマのセットです。

// * require("tag-it");にはTag-itライブラリが含まれています。Tag-itはjQuery UIプラグインで、順序なしリストをタグを入力/作成するためのユニークなユーザーインターフェイスに変えます。
require("jquery-ui");
require("tag-it");

// $(document).on("turbolinks:load", () => {
//   // - 書籍のとおりにすると下記がないというエラーが出るため、下記を追加した
//   if (!jQuery.fn.andSelf) {
//     jQuery.fn.andSelf = jQuery.fn.addBack;
//   }

//   if ($("#tag-it").length) {
//     $("#tag-it").tagit();
//   }
// });

// ¥ 2.ch.12.2.5 タグ付け - タグの追加・削除
$(document).on("turbolinks:load", () => {
  // - 書籍のとおりにすると下記がないというエラーが出るため、下記を追加した
  if (!jQuery.fn.andSelf) {
    jQuery.fn.andSelf = jQuery.fn.addBack;
  }
  if ($("#tag-it").length) {
    const messageId = $("#tag-it").data("message-id");
    const path = $("#tag-it").data("path");
    console.log("path :>> ", path); //path :>>  /messages/62/tag

    $("#tag-it").tagit({
      afterTagAdded: (e, ui) => {
        if (ui.duringInitialization) return;
        $.post(path, { label: ui.tagLabel });
      },
      // * DELETEメソッドでAjax呼び出しをする場合は、このように書きます。公式として、このままの形で覚えてください。
      afterTagRemoved: (e, ui) => {
        if (ui.duringInitialization) return;
        $.ajax({ type: "DELETE", url: path, data: { label: ui.tagLabel } });
      },
    });
  }
});
