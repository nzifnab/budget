#= require application/accounts/account
describe "Account", ->
  beforeEach ->
    window.Account = budget.Account

  afterEach ->
    window.Account = null

  describe ".events", ->
    beforeEach ->
      loadFixtures("account/account_form.html")
      sinon.stub(Account, "create").returns(new Account(71, "blah blah"))
      sinon.stub(budget, "clearForm")
      sinon.stub(Account, "refresh")

    afterEach ->
      Account.create.restore()
      budget.clearForm.restore()
      Account.refresh.restore()

    xit "binds the ajax:success event to an update-account form", ->
      $form = $(".js-update-account")
      expect($form).not.toHandle('ajax:success')
      Account.events()
      expect($(".js-account-accordion")).toHandle('ajax:success')
      expect($form).toHandle('ajax:success')

    it "runs the '.create' method if the response contains html", ->
      Account.events()
      expect(Account.create).not.toHaveBeenCalled()
      $(".js-update-account").trigger(
        "ajax:success",
        [JSON.parse(readFixtures("account/account.json")),
        'success',
        {status: 200}]
      )
      expect(Account.create).toHaveBeenCalledOnce()

    it "doesn't run '.create' if there is no html in the response", ->
      Account.events()
      expect(Account.create).not.toHaveBeenCalled()
      $(".js-update-account").trigger(
        "ajax:success",
        [{accounts: [accountId: 22], auto_open: 22},
        'success',
        {status: 200}]
      )
      expect(Account.create).not.toHaveBeenCalled()

    it "doesn't run '.create' if the status code was not 200", ->
      Account.events()
      $(".js-update-account").trigger(
        "ajax:success",
        [JSON.parse(readFixtures("account/account.json")),
        'success',
        {status: 500}]
      )
      expect(Account.create).not.toHaveBeenCalledOnce()

    it "clears the form on success", ->
      $form = $(".js-update-account")
      Account.events()
      $(".js-update-account").trigger(
        "ajax:success",
        [JSON.parse(readFixtures("account/account.json")),
        'success',
        {status: 200}]
      )
      expect(budget.clearForm).toHaveBeenCalled()

    xit "binds the ajax:error event to the update-account form", ->
      $form = $(".js-update-account")
      expect($form).not.toHandle('ajax:error')
      Account.events()
      expect($form).toHandle('ajax:error')

    it "runs the '.create' method if the response contains html", ->
      Account.events()
      expect(Account.create).not.toHaveBeenCalled()
      $(".js-update-account").trigger(
        "ajax:error",
        [
          {responseText: '{"html":"NEW HTML"}'},
          422,
          'Unprocessable Entity'
        ]
      )
      expect(Account.create).toHaveBeenCalledOnce()

  describe ".create", ->
    beforeEach ->
      @account = new Account(4, "some html")
      sinon.stub(Account, 'init').returns @account
      sinon.stub(@account, 'render')

      @data = {
        html: 'some html',
        accountId: 4,
        sort_weight: "1080000"
      }

    afterEach ->
      Account.init.restore()
      @account.render.restore()

    it "instantiates a new account", ->
      Account.create(@data)
      expect(Account.init).toHaveBeenCalledWith(4, 'some html')

    it "renders the account", ->
      Account.create(@data)
      expect(@account.render).toHaveBeenCalledWith("1080000")

  describe "new instance", ->
    beforeEach ->
      @account = new Account(5, "some html")

    it "sets the id property", ->
      expect(@account.id).toBe(5)

    it "sets the html property", ->
      expect(@account.html).toBe("some html")

    describe "no id supplied", ->
      beforeEach ->
        loadFixtures("account/dummy_accordion.html")
        @account = new Account()

      it "sets the header to that of the 'New Account' container", ->
        expect(@account.$headerDom()[0]).toBe($("#new-account-header")[0])

      it "sets the content to that of the 'New Account' container", ->
        expect(@account.$contentDom()[0]).toBe($("#new-account-content")[0])

  describe "#render", ->
    beforeEach ->
      @data = JSON.parse(readFixtures("account/account.json")).accounts[0]
      @account = new Account(@data.id, @data.html)
      @nearAccount = new Account()
      sinon.stub(@account, "insertNextTo")
      sinon.spy(@account, "remove")
      sinon.stub(@account, 'insertLocation').returns(@nearAccount)

    afterEach ->
      @account.remove.restore()
      @account.insertNextTo.restore()
      @account.insertLocation.restore()

    it "removes the old DOM from the page", ->
      @account.render(8, true)
      expect(@account.remove).toHaveBeenCalledOnce()

    it "locates the correct location to insert the new content", ->
      @account.render(7, true)
      expect(@account.insertLocation).toHaveBeenCalledOnce()

    it "inserts the html next to the located account", ->
      @account.render(6, true)
      expect(@account.insertNextTo).toHaveBeenCalledWith(@nearAccount)

    it "sets the sortWeight of the account", ->
      @account.render("03214")
      expect(@account.sortWeight()).toBe("03214")

  describe "#remove", ->
    beforeEach ->
      loadFixtures("account/dummy_accordion")

    it "locates and removes the content based on the accountId", ->
      account = new Account(15)
      expect($("#account1-content")).toExist()
      account.remove()
      expect($("#account1-content")).not.toExist()

    it "locates and removes the header based on the accountId", ->
      account = new Account(9)
      expect($("#account2-header")).toExist()
      account.remove()
      expect($("#account2-header")).not.toExist()

    it "doesn't remove any other un-related content", ->
      account = new Account(15)
      expect($("#account2-header")).toExist()
      expect($("#account2-content")).toExist()
      expect($("#new-account-header")).toExist()
      expect($("#new-account-content")).toExist()
      account.remove()
      expect($("#account2-header")).toExist()
      expect($("#account2-content")).toExist()
      expect($("#new-account-header")).toExist()
      expect($("#new-account-content")).toExist()

  describe "#refresh", ->
    beforeEach ->
      @oldEffects = budget.Effects
      budget.Effects = {refreshAccordion: sinon.stub()}
      @account = new Account(1, 'hi')

    afterEach ->
      budget.Effects = @oldEffects

    it "should refresh the accordion on the page", ->
      Account.refresh(12)
      expect(budget.Effects.refreshAccordion).toHaveBeenCalledWith(12)

  describe "#insertLocation", ->
    beforeEach ->
      @account = new Account(99)
      loadFixtures("account/dummy_accordion")

    it "returns the first account that has a lower sortWeight", ->
      @account._sortWeight = "107000"
      insertion = @account.insertLocation()
      expect(insertion.$headerDom()[0]).toBe($("#account2-header")[0])

    it "sets the insertionDirection to 'before' when a location is matched", ->
      @account._sortWeight = "107000"
      insertion = @account.insertLocation()
      expect(@account.insertionDirection).toBe('before')

    it "returns the last account if there are no lower sort weights", ->
      @account._sortWeight = "0069500"
      insertion = @account.insertLocation()
      expect(insertion.$headerDom()[0]).toBe($("#account5-header")[0])

    it "sets the content to be added 'after' when there are no lower priorities", ->
      @account._sortWeight = "0069500"
      insertion = @account.insertLocation()
      expect(@account.insertionDirection).toBe('after')

    it "returns the new account container if there are no accounts", ->
      @account.sortWeight = "10500"
      $(".js-account").remove()
      insertion = @account.insertLocation()
      expect(insertion.$headerDom()[0]).toBe($("#new-account-header")[0])

    it "sets the content to be added 'after' when there are no accounts", ->
      @account.sortWeight = "10500"
      $(".js-account").remove()
      insertion = @account.insertLocation()
      expect(@account.insertionDirection).toBe('after')

    it "sorts properly even for very large account amounts", ->
      @account._sortWeight = "10351800957283972800"
      insertion = @account.insertLocation()
      expect(insertion.$headerDom()[0]).toBe($("#account3-header")[0])
      expect(@account.insertionDirection).toBe('before')


    describe "an account object with no id (new account form)", ->
      beforeEach ->
        @account = new Account()
        @account.remove()

      it "returns the first account in the list", ->
        insertion = @account.insertLocation()
        expect(insertion.$headerDom()[0]).toBe($("#account1-header")[0])

      it "sets the insertionDirection to 'before'", ->
        @account.insertLocation()
        expect(@account.insertionDirection).toBe('before')

      it "returns null if there are no other accounts", ->
        $(".accordion-header").remove()
        $(".accordion-content").remove()
        insertion = @account.insertLocation()
        expect(insertion).toBe(null)

      it "sets insertDirection to 'replace' if there are no other accounts", ->
        $(".accordion-header").remove()
        $(".accordion-content").remove()
        @account.insertLocation()
        expect(@account.insertionDirection).toBe('replace')

  describe "#insertNextTo", ->
    beforeEach ->
      loadFixtures("account/dummy_accordion")
      @account = new Account(5, "<div id='some-new-content'></div>")
      @locationAccount = new Account(50)

    it "puts data before the account", ->
      @account.insertionDirection = 'before'
      expect($("#some-new-content")).not.toExist()

      @account.insertNextTo(@locationAccount)

      expect($("#account3-header")).toBeMatchedBy(
        "#some-new-content + #account3-header"
      )

    it "puts data after the account", ->
      @account.insertionDirection = 'after'
      expect($("#some-new-content")).not.toExist()

      @account.insertNextTo(@locationAccount)

      expect($("#some-new-content")).toBeMatchedBy(
        "#account3-content + #some-new-content"
      )

    it "replaces the entire accordion", ->
      expect($(".accordion-header")).toExist()
      expect($(".accordion-content")).toExist()
      expect($("#some-new-content")).not.toExist()

      @account.insertionDirection = 'replace'
      @account.insertNextTo(null)

      expect($("#some-new-content")).toExist()
      expect($("#some-new-content")).toBeMatchedBy(
        ".js-account-accordion #some-new-content"
      )

      expect($(".accordion-header")).not.toExist()
      expect($(".accordion-content")).not.toExist()
