budget.register {
  className: 'dynamicUpdate'

  globalEvents: =>
    $(document).on(
      {
        'ajax:success': (e, data, status, xhr) =>
          if xhr.status == 200 && data.dynamicUpdate?
            for values in data.dynamicUpdate
              $(values.selector).html(values.html) if values.selector?
      },
      '.js-update-content'
    )
}
