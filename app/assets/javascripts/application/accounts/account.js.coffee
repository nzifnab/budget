class Account
  @name: 'Account'

  @init: (args...) ->
    new this(args...)

  constructor: (@id, @html=null) ->
    @insertionDirection = null

    unless @id?
      @$_headerDom = $(".accordion-header").first()
      @$_contentDom = $(".accordion-content").first()

  # renders new @html into the dom as an accordion element
  render: (newPriority, enabled) ->
    throw "No new html found" unless @html?
    @remove()
    @_priority = newPriority
    @_enabled = enabled
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
    @$_headerDom ||= $(".js-account[data-account-id=#{@id}]")

  # accordion content
  $contentDom: ->
    @$_contentDom ||= @$headerDom().next('.js-account-content')

  # accordion 0-based index
  accordionId: ->
    @_accordionId ||= $(".accordion-header").index(@$headerDom())

  # returns a nearby accordion element account object where this
  # account can be placed
  insertLocation: ->
    @insertionDirection = 'after'
    enableSelector = if @enabled() then '[data-enabled]' else ':not([data-enabled])'
    for i in [(@priority() - 1)..0]
      if($headers = $(".js-account[data-priority=#{i}]#{enableSelector}")).length > 0
        @insertionDirection = 'before'
        break
    if $headers.length <= 0
      $headers = $(".js-account#{enableSelector}:last")
    if $headers.length <= 0
      $headers = if @enabled() then $(".accordion-header:first") else $(".accordion-header:last")

    Account.init($headers.first().data('account-id'))

  # Inserts new html before/after (as appropriate) the given account
  # (particularly useful when used with `insertLocation`)
  insertNextTo: (locationAccount, direction=@insertionDirection) ->
    if direction == 'before'
      locationAccount.before(@html)
    else if direction == 'after'
      locationAccount.after(@html)
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
    $(".js-update-account").on
      'ajax:success': (e, data, status, xhr) =>
        if xhr.status == 200 && data.html?
          @create(data)
          budget.clearForm()

budget.register Account
