require "hand"

class PlayerHand < Hand

  property stood : Bool
  property played : Bool

  def initialize
    super
    @stood = false
    @played = false
  end

  # def busted?
  #   get_value(Hand::Soft) > 21
  # end

  def get_value(count_method : Hand::CountMethod)
    total = 0

    cards.each_with_index do |card, index|
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

  def draw(index : Int32)
    
  end

  def is_done?

  end

  def can_split?

  end

  def can_dbl?

  end

  def can_stand?

  end

  def can_hit?

  end

  def hit
  
  end

  def dbl

  end

  def stand

  end

  def process

  end

  def get_action

  end
end
