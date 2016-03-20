class Account
  @$accordionContainer: -> $(".js-account-accordion")
  @className: 'Account'

  @init: (args...) ->
    new @(args...)

  constructor: (@id, @html=null) ->
    @insertionDirection = null

    unless @id?
      @_sortWeight = "10000"

  # renders new @html into the dom as an accordion element
  render: (@_sortWeight) ->
    throw "No new html found" unless @html?
    @remove()
    @insertNextTo(@insertLocation())
    this

  # removes the accordion element
  remove: ->
    @$contentDom().remove()
    @$headerDom().remove()
    @$_headerDom = null
    @$_contentDom = null
    @_accordionId = null

  # refreshes accordion
  @refresh: (newAccordionId) ->
    budget.Effects.refreshAccordion(newAccordionId)


  sortWeight: ->
    @_sortWeight ?= String(@$headerDom().data('sort-weight'))

  # accordion header
  $headerDom: ->
    @$_headerDom ?= do =>
      if @id?
        $(".js-account[data-account-id=#{@id}]")
      else
        $(".accordion-header").first()

  # accordion content
  $contentDom: ->
    @$_contentDom ?= do =>
      if @id?
        @$headerDom().next('.js-account-content')
      else
        $(".accordion-content").first()

  # accordion 0-based index
  accordionId: ->
    $(".accordion-header").index(@$headerDom())

  # returns a nearby accordion element account object where this
  # account can be placed
  insertLocation: ->
    @insertionDirection = 'after'

    if !@id?
      $headers = $(".js-account:first")
      @insertionDirection = 'before'
    else
      $headers = []
      $(".js-account").each (index, element) =>
        $headers = $(element)
        if String(@sortWeight()) > String($headers.data('sort-weight'))
          @insertionDirection = 'before'
          return false
      if $headers.length <= 0
        $headers = $(".js-account:last")

    if $headers.length <= 0
      $headers = $(".accordion-header:last")
    if $headers.length <= 0
      @insertionDirection = 'replace'
      return null

    Account.init($headers.first().data('account-id'))

  # Inserts new html before/after (as appropriate) the given account
  # (particularly useful when used with `insertLocation`)
  insertNextTo: (locationAccount, direction=@insertionDirection) ->
    if direction == 'before'
      locationAccount.before(@html)
    else if direction == 'after'
      locationAccount.after(@html)
    else if direction == 'replace'
      Account.$accordionContainer().html(@html)
    else
      throw "Only 'before' and 'after' allowed for direction"

  before: (html) ->
    @$headerDom().before(html)

  after: (html) ->
    @$contentDom().after(html)

  # creates/updates an accordion based on the account id and other
  # data returned from the ajax request.
  @create: (data) ->
    html = data.html
    id = data.accountId
    account = (@init(id, html)).render(data.sort_weight)

  @clear: ->
    budget.clearForm()
    $(".form-error-container").remove()
    $form = $(".js-account-content .js-update-account")
    $accountHeader = $form.closest(".js-account-content").prev(".js-account")
    $accountHeader.each (index, element) =>
      id = $(element).data("account-id")
      $(".js-account-content-#{id}").show()
      $("#edit_account_#{id}").remove()


  @events: =>
    $('.js-account-accordion').on(
      {
        'ajax:success': (e, data, status, xhr) =>
          $(".js-account .header-notice").remove()
          if xhr.status == 200 && data.newFormHtml?
            newForm = @create(html: data.newFormHtml)

          if xhr.status == 200 && data.accounts?
            auto_open = null
            for account in data.accounts
              if account.html?
                m = @create(account)
                if data.auto_open == account.accountId
                  auto_open = m
            @refresh(auto_open?.accordionId())
            Account.clear()
          else if xhr.status == 200 && data.html?
            account = @create(data)
            @refresh(account.accordionId())
            Account.clear()

        'ajax:error': (e, xhr, status, error) =>
          $(".js-account .header-notice").remove()
          data = JSON.parse(xhr.responseText)
          account = @create(data)
          @refresh(account.accordionId())
      },
      '.js-update-account'
    )

budget.register Account
