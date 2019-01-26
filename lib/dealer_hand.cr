require "hand"

class DealerHand < Hand

  property hide_down_card : Bool

  def initialize
    super
    @hide_down_card = true
  end
  
  def up_card_is_ace?
    cards.first.is_ace?
  end

  # def busted?
  #   get_value(Hand::Soft) > 21
  # end

  def get_value(count_method : Hand::CountMethod)
    total = 0

    cards.each_with_index do |card, index|
      next if index == 1 && hide_down_card
      tmp_v = card.value + 1
      v = tmp_v > 9 ? 10 : tmp_v
      v = 11 if count_method == Hand::Soft && v == 1 && total < 11
      total += v
    end

    if count_method == Hand::Soft && total > 21
      get_value(Hand::Hard)
    else
      total
    end
  end

  def draw
    
  end
end
