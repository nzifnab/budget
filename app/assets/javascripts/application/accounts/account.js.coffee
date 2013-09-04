# TODO:  the new element should be positioned at the top of the
# similar-priority list, not the bottom.  Also, if other elements
# of that enabled flag were not found, position the element after
# the first element (for enabled=true) and after the last element
# (for enabled=false).
#
# aka. emulate behavior from old version:

#    var foundSolution = false;
#    // Loops through each item in the section and selects
#    // the first element that should be *below* our data.
#    group.each(function(){
#      if($(this).data('priority') < priority){
#        foundSolution = $(this);
#        return false;
#      }
#    });
#
#    if(foundSolution){
#      // If an appropriate element was found, position our data before it
#      foundSolution.before(data);
#    }else{
#      if(group.length == 0){
#        // If there was nothing in the group, place the data at the top or the bottom,
#        // depending on it's enabled flag
#        subselect = (enabled == 0) ? 'last' : 'first';
#        $('h3.accordion-header:' + subselect).next().after(data)
#      }else{
#        // The group did have content, so put our data at the end of it.
#        group.last().next().after(data);
#      }
#    }

class Account
  @name: 'Account'

  constructor: (@id, @html=null) ->
    unless @id?
      @$_headerDom = $(".accordion-header").first()
      @$_contentDom = $(".accordion-content").first()

  render: (newPriority, enabled) ->
    throw "No new html found" unless @html?
    @remove()
    nearestAccount = Account.lastNearPriority(newPriority, enabled)
    nearestAccount.$contentDom().after(@html)
    @refresh(@accordionId())

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
