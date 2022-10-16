require "spec"
require "../lib/dealer_hand"

def new_dealer_hand
  DealerHand.new
end

describe DealerHand do
  describe "a new dealer hand" do
    it "has an empty cards array" do
      new_dealer_hand.cards.should eq([] of Card)
    end

    it "has a hidden down card" do
      new_dealer_hand.hide_down_card.should be_truthy
    end
  end
end
