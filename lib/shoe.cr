require "card"

class Shoe

  property num_decks : Int32
  property cards : Array(Card) = [] of Card

  def initialize(@num_decks)
    new_regular
  end

  def next_card
    @cards.pop
  end

  def deal_card(hand : Hand)
    hand.cards << next_card
  end

  def needs_to_shuffle?
    # TODO: build actual shuffle specs
    true
  end

  def shuffle
    @cards.shuffle!
  end

  def new_regular
    @cards.clear
    
    num_decks.times do
      4.times do |suite|
        13.times do |value|
          @cards << Card.new(value, suite)
        end
      end
    end

    shuffle
  end
end
