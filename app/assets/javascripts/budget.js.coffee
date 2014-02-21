class Budget
  constructor: ->
    @events = []
    @globalEvents = []
    @teardowns = []
    @initialize()

  initialize: ->
    $ =>
      @triggerEvents(@globalEvents)
    # By god this should be the only call to $(document).ready() EVER
    $(document).on 'ready page:load', (e) =>
      @triggerEvents(@events)

    $(document).on 'page:before-change', (e) =>
      @triggerEvents(@teardowns)

  register: (classToRegister) ->
    # Requires classToRegister to respond to the following:
    #   @name
    #
    # Optionally instances of classToRegister can respond to:
    #   events - a function that will execute on $(document).ready
    #   globalEvents - events bound directly to $(document) that will be
    #                  executed directly.  Use sparingly, consider memory leak implications.
    #
    # TODO: Really need to have a sensible unbinding mechanism that will unbind on pjax page
    # change so that we aren't leaking event memory which I think is actually somewhat of a problem
    # right now, particularly for events that are bound to $(document) and other elements not removed
    # on pjax change.
    throw "class #{classToRegister.name} must respond to className" unless classToRegister.className?
    this[classToRegister.className] = classToRegister
    if classToRegister.events?
      @events.push(classToRegister.events)
    if classToRegister.globalEvents?
      @globalEvents.push(classToRegister.globalEvents)
    if classToRegister.teardown?
      @teardowns.push(classToRegister.teardown)

  triggerEvents: (events) ->
    for theEvent in events
      theEvent()

  redirect: (url) ->
    window.location = url

window.budget = new Budget()
