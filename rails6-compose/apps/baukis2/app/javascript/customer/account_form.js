// # ¥ 2.ch.9.1.4 顧客自身によるアカウント管理機能
function toggle_home_address_fields() {
  const checked = $("input#form_inputs_home_address").prop("checked");
  $("fieldset#home-address-fields input").prop("disabled", !checked);
  $("fieldset#home-address-fields select").prop("disabled", !checked);
  $("fieldset#home-address-fields").toggle(checked);
}

function toggle_work_address_fields() {
  const checked = $("input#form_inputs_work_address").prop("checked");
  $("fieldset#work-address-fields input").prop("disabled", !checked);
  $("fieldset#work-address-fields select").prop("disabled", !checked);
  $("fieldset#work-address-fields").toggle(checked);
}

$(document).on("ready turbolinks:load", () => {
  // ¥ 2.ch.9.3.7
  // 確認画面では、自宅住所セクションや勤務先セクションの表示・非表示を切り替える処理を行わないようにしている
  if ($("div.confirming").length) return;
  toggle_home_address_fields();
  toggle_work_address_fields();
  $("input#form_inputs_home_address").on("click", () => {
    toggle_home_address_fields();
  });
  $("input#form_inputs_work_address").on("click", () => {
    toggle_work_address_fields();
  });
});
