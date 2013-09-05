#= require application/accounts/account
describe "Account", ->
  beforeEach ->
    window.Account = budget.Account

  afterEach ->
    window.Account = null

  describe ".events", ->
    beforeEach ->
      loadFixtures("account/account_form.html")
      sinon.stub(Account, "create")

    afterEach ->
      Account.create.restore()

    it "binds the ajax:success event to an update-account form", ->
      $form = $(".js-update-account")
      expect($form).not.toHandle('ajax:success')
      Account.events()
      expect($form).toHandle('ajax:success')

    it "runs the '.create' method if the response contains accountHTML", ->
      Account.events()
      expect(Account.create).not.toHaveBeenCalled()
      $(".js-update-account").trigger(
        "ajax:success",
        JSON.parse(readFixtures("account/account.json")),
        200,
        null
      )
      expect(Account.create).toHaveBeenCalledOnce()

    it "doesn't run '.create' if there is no accountHTML in the response", ->
      Account.events()
      expect(Account.create).not.toHaveBeenCalled()
      $(".js-update-account").trigger(
        "ajax:success",
        {accountId: 22},
        200,
        null
      )
      expect(Account.create).not.toHaveBeenCalled()

  describe ".create", ->
    beforeEach ->
      @account = new Account(4, "some html")
      sinon.stub(Account, 'init').returns @account
      sinon.stub(@account, 'render')

      @data = {
        accountHTML: 'some html',
        accountId: 4,
        priority: 8,
        enabled: true
      }

    afterEach ->
      Account.init.restore()
      @account.render.restore()

    it "instantiates a new account", ->
      Account.create(@data)
      expect(Account.init).toHaveBeenCalledWith(4, 'some html')

    it "renders the account", ->
      Account.create(@data)
      expect(@account.render).toHaveBeenCalledWith(8, true)

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
        expect(@account.$headerDom()).toBe($("#new-account-header"))

      it "sets the content to that of the 'New Account' container", ->
        expect(@account.$contentDom()).toBe($("#new-account-content"))

  describe "#render", ->
    beforeEach ->
      @data = JSON.parse readFixtures("account/account.json")
      @account = new Account(@data.id, @data.accountHTML)
      @nearAccount = new Account()
      sinon.stub(@nearAccount, "nextTo")
      sinon.spy(@account, "remove")
      sinon.stub(Account, 'insertLocation').returns(@nearAccount)
      sinon.stub(@account, "refresh")

    afterEach ->
      @account.remove.restore()
      @account.refresh.restore()
      @nearAccount.nextTo.restore()
      Account.insertLocation.restore()

    it "removes the old DOM from the page", ->
      @account.render(8, true)
      expect(@account.remove).toHaveBeenCalledOnce()

    it "locates the correct location to insert the new content", ->
      @account.render(7, true)
      expect(Account.insertLocation).toHaveBeenCalledWith(7, true)

    it "inserts the html next to the located account", ->
      @account.render(6, true)
      expect(@nearAccount.nextTo).toHaveBeenCalledWith(@data.accountHTML)

    it "refreshes the accordion view", ->
      @account.render(5, true)
      expect(@account.refresh).toHaveBeenCalledOnce()

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
      @account.refresh(12)
      expect(budget.Effects.refreshAccordion).toHaveBeenCalledWith(12)

  describe "#priority", ->
    it "returns the priority data-attribute from the header dom", ->
      account = new Account()
      account.$_headerDom = $("<div data-priority=4></div>")
      expect(account.priority()).toBe(4)
