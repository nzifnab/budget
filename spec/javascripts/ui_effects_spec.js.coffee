#= require application/accounts/ui_effects
describe "Effect", ->
  beforeEach ->
    window.Effects = budget.Effects

  afterEach ->
    window.Effects = null

  describe ".initRemoteHide", ->
    it "hides the content specified", ->
      loadFixtures("effects/remote_hiding")

      Effects.initRemoteHide()
      expect($(".thing-to-hide")).toBeVisible()
      $(".link-that-hides").trigger("ajax:complete")
      expect($(".thing-to-hide")).not.toBeVisible()

  describe ".initRemoteContentAppend", ->
    it "appends the returned content to the area specified", ->
      $content = $("<div class='appended-content'>Some things</div>")
      loadFixtures("effects/remote_content_append")

      Effects.initRemoteContentAppend()
      expect($(".parent-element").length).toBe(1)
      expect($(".parent-element + .appended-content").length).toBe(0)
      $(".link-that-appends").trigger("ajax:success", $content)
      expect($(".parent-element + .appended-content").length).toBe(1)