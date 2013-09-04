class Account
  @name: 'Account'

  constructor: (@id, @html=null) ->
    unless @id?
      @$_headerDom = $(".accordion-header").first()
      @$_contentDom = $(".accordion-content").first()

  render: (newPriority, enabled) ->
    throw "No new html found" unless @html?
    #$(".js-account[data-account-id=#{@id}]").remove()
    @remove()
    #priority = parseInt @html.find('.js-account').data('priority')
    nearestAccount = Account.lastNearPriority(newPriority, enabled)
    nearestAccount.$contentDom().after(@html)
    @refresh(nearestAccount.accordionId() + 1)

  remove: ->
    @$contentDom().remove()
    @$headerDom().remove()
    @$_headerDom = null
    @$_contentDom = null
    @_accordionId = null

  refresh: (newAccordionId) ->
    budget.Effects.refreshAccordion(newAccordionId)

  priority: ->
    parseInt $headerDom().data('priority')

  $headerDom: ->
    @$_headerDom ||= $(".js-account[data-account-id=#{@id}]")

  $contentDom: ->
    @$_contentDom ||= @$headerDom().next('.js-account-content')

  accordionId: ->
    @_accordionId ||= $(".accordion-header").index(@$headerDom())

  @create: (data) ->
    html = data.accountHTML
    id = data.accountId
    (new Account(id, html)).render(data.priority, data.enabled)

  @lastNearPriority: (priority, enabled) ->
    enableSelector = if enabled? then '[data-enabled]' else ':not([data-enabled])'
    for i in [priority..10]
      if($headers = $(".js-account[data-priority=#{i}]#{enableSelector}")).length > 0
        break
    if $headers.length <= 0
      $headers = $(".js-account[data-priority=11]")
    new Account($headers.last().data('account-id'))

  @events: =>
    $(".js-update-account").on
      'ajax:success': (e, data, status, xhr) =>
        if data.accountHTML?
          @create(data)

budget.register Account
