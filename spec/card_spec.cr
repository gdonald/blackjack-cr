require "spec"
require "../lib/card"
require "../lib/game"

def new_game
  Game.new
end

describe Card do
  it "has FACES" do
    Card::FACES[2][3].should eq "3♦"
  end

  it "FACES has a dealer down card" do
    card = Card.new(13, 0)
    Card.draw(new_game, card).should eq "??"
  end

  it "#draw" do
    card = Card.new(2, 3)
    Card.draw(new_game, card).should eq "3♦"
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
