require 'spec_helper_lite'
require_relative '../../app/helpers/application_helper'

describe ApplicationHelper do
  class TestHelper
    include ApplicationHelper
  end

  let(:helper){TestHelper.new}

  describe ".nice_date" do
    it "formats the date" do
      time_now = "April 2, 1985".to_datetime
      helper.nice_date(time_now).should == "Apr 02, 1985"
    end
  end
end
