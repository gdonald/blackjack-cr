require "hand"

class PlayerHand < Hand

  property stood : Bool = false
  property played : Bool = false
  property status : Hand::Status = Status::Unknown
  property bet : Int32

  def initialize(@bet)
  end

  # def busted?
  #   get_value(Hand::Soft) > 21
  # end

  def get_value(count_method : Hand::Count)
    total = 0

    cards.each_with_index do |card, index|
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

  def draw(index : Int32)
    output = " "

    cards.each_with_index do |card, index|
      output += "#{card} "
    end

    output += " ⇒  #{get_value(Count::Soft)} "

    if status == Status::Lost
      output += "-"
    elsif status == Status::Won
      output += "+"
    end

    output += " #{Game.format_money(bet)}"
    # TODO: add current and status here

    output
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
