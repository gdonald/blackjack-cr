require "./card"

class Shoe

  class_property shuffle_specs = [80, 81, 82, 84, 86, 89, 92, 95]

  property num_decks : Int32
  property cards : Array(Card) = [] of Card

  def initialize(@num_decks)
  end

  def next_card
    cards.pop
  end

  def deal_card(hand : Hand)
    hand.cards << next_card
  end

  def needs_to_shuffle?
    return true if cards.size == 0

    total_cards = get_total_cards
    cards_dealt = total_cards - cards.size
    used = cards_dealt / total_cards * 100.0

    used > Shoe.shuffle_specs[num_decks - 1]
  end

  def shuffle
    cards.shuffle!
  end

  def get_total_cards
    total_cards = num_decks * 52
  end

  def new_shoe(values : Array(Int32))
    total_cards = get_total_cards
    cards.clear

    while cards.size < total_cards
      4.times do |suit|
        values.each do |value|
          break if cards.size >= total_cards
          cards << Card.new(value, suit)
        end
      end
    end

    shuffle
  end

  def new_regular
    new_shoe((0..12).to_a)
  end

  def new_aces
    new_shoe([0])
  end

  def new_jacks
    new_shoe([10])
  end

  def new_aces_jacks
    new_shoe([0, 10])
  end

  def new_sevens
    new_shoe([6])
  end

  def new_eights
    new_shoe([7])
  end
end
