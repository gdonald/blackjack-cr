require "card"

class Hand
  enum Status
    Unknown
    Won
    Lost
    Push
  end
  
  enum Count
    Soft
    Hard
  end

  property cards : Array(Card) = [] of Card

  def initialize
  end

  def busted?
    get_value(Hand::Soft) > 21
  end

  def is_blackjack?
    return false unless cards.size == 2
    c1, c2 = cards
    (c1.is_ace? && c2.is_ten?) || (c2.is_ace? && c1.is_ten?)
  end

  def done?
    false
  end
end
