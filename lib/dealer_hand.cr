require "hand"

class DealerHand < Hand

  property hide_down_card : Bool = true

  def initialize
  end
  
  def up_card_is_ace?
    cards.first.is_ace?
  end

  def get_value(count_method : Hand::Count)
    total = 0

    cards.each_with_index do |card, index|
      next if index == 1 && hide_down_card
      tmp_v = card.value + 1
      v = tmp_v > 9 ? 10 : tmp_v
      v = 11 if count_method == Count::Soft && v == 1 && total < 11
      total += v
    end

    if count_method == Count::Soft && total > 21
      get_value(Count::Hard)
    else
      total
    end
  end

  def draw
    output = " "

    cards.each_with_index do |card, index|
      output += (index == 1 && hide_down_card ? Card::FACES[13][0] : card.to_s)
      output += " "
    end

    output += " ⇒  #{get_value(Count::Soft)}"
  end
end
