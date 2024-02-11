require "./hand"

class DealerHand < Hand

  property hide_down_card : Bool = true

  def initialize
  end

  def self.is_busted?(dealer_hand : DealerHand)
    DealerHand.get_value(dealer_hand, Count::Soft) > 21
  end
  
  def up_card_is_ace?
    cards.first.is_ace?
  end

  def self.get_value(dealer_hand : DealerHand, count_method : Hand::Count)
    total = 0

    dealer_hand.cards.each_with_index do |card, index|
      next if index == 1 && dealer_hand.hide_down_card
      tmp_v = card.value + 1
      v = tmp_v > 9 ? 10 : tmp_v
      v = 11 if count_method == Count::Soft && v == 1 && total < 11
      total += v
    end

    if count_method == Count::Soft && total > 21
      DealerHand.get_value(dealer_hand, Count::Hard)
    else
      total
    end
  end

  def self.draw(game : Game, dealer_hand : DealerHand)
    output = " "

    dealer_hand.cards.each_with_index do |card, index|
      output += (index == 1 && dealer_hand.hide_down_card ? Card.draw(game, Card.new(13, 0)) : Card.draw(game, card))
      output += " "
    end

    output += " ⇒  #{DealerHand.get_value(dealer_hand, Count::Soft)}"
  end
end
