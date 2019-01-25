class Card
  FACES = [["🂡", "🂱", "🃁", "🃑"],
           ["🂢", "🂲", "🃂", "🃒"],
	   ["🂣", "🂳", "🃃", "🃓"],
	   ["🂤", "🂴", "🃄", "🃔"],
	   ["🂥", "🂵", "🃅", "🃕"],
	   ["🂦", "🂶", "🃆", "🃖"],
	   ["🂧", "🂷", "🃇", "🃗"],
	   ["🂨", "🂸", "🃈", "🃘"],
	   ["🂩", "🂹", "🃉", "🃙"],
	   ["🂪", "🂺", "🃊", "🃚"],
	   ["🂫", "🂻", "🃋", "🃛"],
	   ["🂭", "🂽", "🃍", "🃝"],
	   ["🂮", "🂾", "🃎", "🃞"],
	   ["🂠", "",  "",  "" ]]

  getter value : Int32
  getter suite : Int32

  def initialize(@value, @suite)
  end

  def to_s(io)
    io << Card::FACES[value][suite]
  end

  def is_ace?
    value == 0
  end

  def is_ten?
    value > 8
  end
end
