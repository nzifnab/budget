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

  @init: (args...) ->
    new this(args...)

  constructor: (@id, @html=null) ->
    @insertionDirection = null

    unless @id?
      @$_headerDom = $(".accordion-header").first()
      @$_contentDom = $(".accordion-content").first()

  render: (newPriority, enabled) ->
    throw "No new html found" unless @html?
    @remove()
    @_priority = newPriority
    @_enabled = enabled
    @insertNextTo(@insertLocation())
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
    @_priority ?= parseInt @$headerDom().data('priority')

  enabled: ->
    @_enabled ?= @$headerDom().data('enabled')?

  $headerDom: ->
    @$_headerDom ||= $(".js-account[data-account-id=#{@id}]")

  $contentDom: ->
    @$_contentDom ||= @$headerDom().next('.js-account-content')

  accordionId: ->
    @_accordionId ||= $(".accordion-header").index(@$headerDom())

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

  @create: (data) ->
    html = data.accountHTML
    id = data.accountId
    (@init(id, html)).render(data.priority, data.enabled)

  @events: =>
    $(".js-update-account").on
      'ajax:success': (e, data, status, xhr) =>
        if data.accountHTML?
          @create(data)

budget.register Account
