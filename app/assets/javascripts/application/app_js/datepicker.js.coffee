budget.register {
  className: "datepicker"

  events: ->
    $(".datepicker").datepicker(
      dateFormat: "MM d, yy"
    )
}
