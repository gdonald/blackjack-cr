require "card"

class Hand
  enum Status
    Unknown
    Won
    Lost
    Push
  end
  
  enum CountMethod
    Soft
    Hard
  end

  property cards : Array(Card)

  def initialize
    @cards = [] of Card
  end

  def busted?
    get_value(Hand::Soft) > 21
  end

  def is_blackjack?
    return false unless cards.size == 2
    return true if cards.first.is_ace? && cards.last.is_ten?
    return true if cards.last.is_ace? && cards.first.is_ten?
  end

  def done?
    false
  end
end
