budget.register {
  className: 'dynamicUpdate'

  globalEvents: =>
    $(document).on(
      {
        'ajax:success': (e, data, status, xhr) =>
          if xhr.status == 200 && data.dynamicUpdate?
            for values in data.dynamicUpdate
              updateType = values.updateType
              if values.selector?
                if updateType == "replace"
                  $(values.selector).replaceWith(values.html)
                else
                  $(values.selector).html(values.html)
      },
      '.js-update-content'
    )
}
