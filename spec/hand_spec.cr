require "spec"
require "../lib/hand"

describe Hand do
  it "has Status enum" do
    expected = ["Unknown", "Won", "Lost", "Push"]
    Hand::Status.names.should eq(expected)
  end

  it "has Count enum" do
    expected = ["Soft", "Hard"]
    Hand::Count.names.should eq(expected)
  end
end
