//- jQueryでは、.toggle()メソッドを複数の方法で使用できます。trueやfalseのようなブーリアン引数で使用すると、ブーリアン値に基づいて、マッチした要素のセットを表示または非表示にします：

//^ .toggle(true) は要素を表示します。
//^ .toggle(false)は要素を非表示にします。

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
  toggle_home_address_fields();
  toggle_work_address_fields();
  $("input#form_inputs_home_address").on("click", () => {
    toggle_home_address_fields();
  });
  $("input#form_inputs_work_address").on("click", () => {
    toggle_work_address_fields();
  });
});
