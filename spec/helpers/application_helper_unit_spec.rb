RSpec.describe ApplicationHelper do
  class TestHelper
    include ApplicationHelper
  end

  let(:helper){TestHelper.new}

  describe ".nice_date" do
    it "formats the date" do
      time_now = "April 2, 1985".to_datetime
      expect(helper.nice_date(time_now)).to eq "Apr 02, 1985"
    end
  end
end
