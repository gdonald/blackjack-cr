require "card"

class Shoe

  class_property shuffle_specs = [
    [95, 8],
    [92, 7],
    [89, 6],
    [86, 5],
    [84, 4],
    [82, 3],
    [81, 2],
    [80, 1]
  ]

  property num_decks : Int32
  property cards : Array(Card) = [] of Card

  def initialize(@num_decks)
    new_regular
  end

  def next_card
    cards.pop
  end

  def deal_card(hand : Hand)
    hand.cards << next_card
  end

  def needs_to_shuffle?
    return true if cards.size == 0
    
    total_cards = num_decks * 52
    cards_dealt = total_cards - cards.size
    used = cards_dealt / total_cards * 100.0

    (0..7).each do |x|
      next unless num_decks == Shoe.shuffle_specs[x][1]
      return true if used > Shoe.shuffle_specs[x][0]
    end

    false
  end

  def shuffle
    cards.shuffle!
  end

  def new_regular
    cards.clear
    
    num_decks.times do
      4.times do |suite|
        13.times do |value|
          cards << Card.new(value, suite)
        end
      end
    end

    shuffle
  end

  def new_aces
    cards.clear
    
    (num_decks * 5).times do
      4.times do |suite|
        cards << Card.new(0, suite)
      end
    end

    shuffle
  end

  def new_jacks
    cards.clear
    
    (num_decks * 5).times do
      4.times do |suite|
        cards << Card.new(10, suite)
      end
    end

    shuffle
  end

  def new_aces_jacks
    cards.clear
    
    (num_decks * 5).times do
      4.times do |suite|
        cards << Card.new(0, suite)
        cards << Card.new(10, suite)
      end
    end

    shuffle
  end

  def new_sevens
    cards.clear
    
    (num_decks * 5).times do
      4.times do |suite|
        cards << Card.new(6, suite)
      end
    end

    shuffle
  end

  def new_eights
    cards.clear
    
    (num_decks * 5).times do
      4.times do |suite|
        cards << Card.new(7, suite)
      end
    end

    shuffle
  end
end
