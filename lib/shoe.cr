require "card"

class Shoe

  class_property shuffle_specs = [80, 81, 82, 84, 86, 89, 92, 95]

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

    used > Shoe.shuffle_specs[num_decks - 1]
  end

  def shuffle
    cards.shuffle!
  end

  def new_regular
    cards.clear

    num_decks.times do
      4.times do |suit|
        13.times do |value|
          cards << Card.new(value, suit)
        end
      end
    end

    shuffle
  end

  def new_aces
    cards.clear

    (num_decks * 5).times do
      4.times do |suit|
        cards << Card.new(0, suit)
      end
    end

    shuffle
  end

  def new_jacks
    cards.clear

    (num_decks * 5).times do
      4.times do |suit|
        cards << Card.new(10, suit)
      end
    end

    shuffle
  end

  def new_aces_jacks
    cards.clear

    (num_decks * 5).times do
      4.times do |suit|
        cards << Card.new(0, suit)
        cards << Card.new(10, suit)
      end
    end

    shuffle
  end

  def new_sevens
    cards.clear

    (num_decks * 5).times do
      4.times do |suit|
        cards << Card.new(6, suit)
      end
    end

    shuffle
  end

  def new_eights
    cards.clear

    (num_decks * 5).times do
      4.times do |suit|
        cards << Card.new(7, suit)
      end
    end

    shuffle
  end
end
