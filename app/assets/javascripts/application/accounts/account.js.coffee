class Account
  @$accordionContainer: -> $(".js-account-accordion")
  @className: 'Account'

  @init: (args...) ->
    new @(args...)

  constructor: (@id, @html=null) ->
    @insertionDirection = null

    unless @id?
      @_enabled = true
      @_priority = 0

  # renders new @html into the dom as an accordion element
  render: (newPriority, newEnabled) ->
    throw "No new html found" unless @html?
    priority = @priority()
    enabled = @enabled()
    @remove()
    @_priority = newPriority ? priority
    @_enabled = newEnabled ? enabled
    @insertNextTo(@insertLocation())
    @refresh(@accordionId())

  # removes the accordion element
  remove: ->
    @$contentDom().remove()
    @$headerDom().remove()
    @$_headerDom = null
    @$_contentDom = null
    @_accordionId = null

  # refreshes accordion
  refresh: (newAccordionId) ->
    budget.Effects.refreshAccordion(newAccordionId)

  # the priority level of this account
  priority: ->
    @_priority ?= parseInt @$headerDom().data('priority')

  enabled: ->
    @_enabled ?= @$headerDom().data('enabled')?

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
    @_accordionId ||= $(".accordion-header").index(@$headerDom())

  # returns a nearby accordion element account object where this
  # account can be placed
  insertLocation: ->
    @insertionDirection = 'after'

    if !@id?
      $headers = $(".js-account:first")
      @insertionDirection = 'before'
    else
      enableSelector = if @enabled() then '[data-enabled]' else ':not([data-enabled])'
      for i in [(@priority() - 1)..0]
        if($headers = $(".js-account[data-priority=#{i}]#{enableSelector}")).length > 0
          @insertionDirection = 'before'
          break
      if $headers.length <= 0
        $headers = $(".js-account#{enableSelector}:last")

    if $headers.length <= 0
      $headers = if @enabled() then $(".accordion-header:first") else $(".accordion-header:last")
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
    (@init(id, html)).render(data.priority, data.enabled)

  @events: =>
    $('.js-account-accordion').on(
      {
        'ajax:success': (e, data, status, xhr) =>
          if xhr.status == 200 && data.html?
            @create(data)
            budget.clearForm()

        'ajax:error': (e, xhr, status, error) =>
          @create(JSON.parse(xhr.responseText))
      },
      '.js-update-account'
    )

budget.register Account
