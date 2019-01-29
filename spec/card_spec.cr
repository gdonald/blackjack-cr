require "spec"
require "../lib/card"

describe Card do
  it "has FACES" do
    Card::FACES[2][3].should eq "🃓"
  end

  it "FACES has a dealer down card" do
    card = Card.new(13, 0)
    "#{card}".should eq "🂠"
  end

  it "#to_s" do
    card = Card.new(2, 3)
    "#{card}".should eq "🃓"
  end

  describe "#is_ace" do
    it "returns true" do
      card = Card.new(0, 0)
      card.is_ace?.should be_true
    end

    it "returns false" do
      card = Card.new(1, 0)
      card.is_ace?.should be_false
    end
  end

  describe "#is_ten" do
    it "returns true" do
      card = Card.new(9, 0)
      card.is_ten?.should be_true
    end

    it "returns false" do
      card = Card.new(8, 0)
      card.is_ten?.should be_false
    end
  end
end
