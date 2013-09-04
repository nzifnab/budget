class Budget
  constructor: ->
    @events = []

    @initialize()

  initialize: ->
    # By god this should be the only call to $(document).ready() EVER
    $(document).on 'ready page:load', (e) =>
      @triggerEvents()

  register: (classToRegister) ->
    # Requires classToRegister to respond to the following:
    #   @name
    # 
    # Optionally instances of classToRegister can respond to:
    #   events
    # which should be a function that will execute on $(document).ready
    throw "Class must respond to #{name}" unless classToRegister.name?
    this[classToRegister.name] = classToRegister
    if classToRegister.events?
      @events.push(classToRegister.events)

  triggerEvents: ->
    for theEvent in @events
      theEvent()

window.budget = new Budget()
