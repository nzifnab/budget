describe "Budget", ->
  describe "#initialize", ->
    beforeEach ->
      sinon.stub(budget, 'triggerEvents')

    afterEach ->
      budget.triggerEvents.restore()

    it "triggers events on page load", ->
      expect(budget.triggerEvents).not.toHaveBeenCalled()
      $(document).trigger('page:load')
      expect(budget.triggerEvents).toHaveBeenCalled()

  describe "#clearForm", ->
    beforeEach ->
      @valFields = [
        "#field1",
        "#field2",
        "#select",
        "#text1",
        "#field3"
      ]
      @checkFields = [
        "#checkbox1",
        "#checkbox2",
        "#checkbox3"
      ]
      loadFixtures("budget/forms")

    it "clears all form elements on the page", ->
      expect($("#form1")).toExist()
      budget.clearForm()
      for fieldName in @valFields
        expect($(fieldName)).toHaveValue('')
      for checkName in @checkFields
        expect($(checkName)).not.toBeChecked()

  describe "#register", ->
    beforeEach ->
      @dummy = {
        events: ->
          'some stuff'
        name: 'DummyClass'
      }

    it "adds the class to the budget namespace", ->
      expect(budget.DummyClass).toBeUndefined()
      budget.register(@dummy)
      expect(budget.DummyClass).toBe(@dummy)

    it "Pushes the events onto the events stack", ->
      expect(budget.events.length).toBe(0)
      budget.register(@dummy)
      expect(budget.events[0]).toBe(@dummy.events)

  describe "#triggerEvents", ->
    beforeEach ->
      @event1 = sinon.stub()
      @event2 = sinon.stub()
      budget.events = [@event1, @event2]

    it "should trigger all events", ->
      budget.triggerEvents()
      expect(@event1).toHaveBeenCalled()
      expect(@event2).toHaveBeenCalled()
