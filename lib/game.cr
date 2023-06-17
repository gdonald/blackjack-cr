require "dealer_hand"
require "player_hand"
require "shoe"

class Game
  SAVE_FILE = "bj.txt"
  MIN_BET = 500.0
  MAX_BET = 10000000.0
  START_MONEY = 10000.0

  property num_decks : Int32 = 8
  property deck_type : Int32 = 1
  property face_type : Int32 = 1
  property current_player_hand : Int32 = 0
  property current_bet : Float64 = 500
  property money : Float64 = START_MONEY
  property quitting : Bool = false

  property shoe : Shoe
  property dealer_hand : DealerHand
  property player_hands : Array(PlayerHand)

  def initialize
    load_game

    @shoe = Shoe.new(num_decks)
    @dealer_hand = DealerHand.new
    @player_hands = [] of PlayerHand
  end

  def run
    while !quitting
      deal_new_hand
    end
  end

  def build_new_shoe
    case deck_type
    when 1
      shoe.new_regular
    when 2
      shoe.new_aces
    when 3
      shoe.new_jacks
    when 4
      shoe.new_aces_jacks
    when 5
      shoe.new_sevens
    when 6
      shoe.new_eights
    else
      shoe.new_regular
    end
  end

  def deal_new_hand
    build_new_shoe if shoe.needs_to_shuffle?

    @dealer_hand = DealerHand.new
    player_hand = PlayerHand.new(self, @current_bet)

    2.times do
      @shoe.deal_card(player_hand)
      @shoe.deal_card(@dealer_hand)
    end

    @player_hands.clear
    @player_hands << player_hand
    @current_player_hand = 0

    if @dealer_hand.up_card_is_ace? && !player_hand.is_blackjack?
      draw_hands
      ask_insurance
      return
    end

    if player_hand.is_done?
      @dealer_hand.hide_down_card = false
      pay_hands
      draw_hands
      bet_options
      return
    end

    draw_hands
    player_hand.get_action
    save_game
  end

  def clear
    system("export TERM=linux; clear")
  end

  def draw_hands
    clear

    puts "\n Dealer: "
    puts DealerHand.draw(self, @dealer_hand)

    puts "\n Player: #{Game.format_money(@money)}:\n"

    @player_hands.each_with_index do |player_hand, index|
      puts PlayerHand.draw(self, player_hand, index)
    end
  end

  def all_bets
    bets = 0
    player_hands.each do |player_hand|
      bets += player_hand.bet
    end
    bets
  end

  def more_hands_to_play
    current_player_hand < player_hands.size - 1
  end

  def play_more_hands
    @current_player_hand += 1

    player_hand = player_hands[current_player_hand]
    shoe.deal_card(player_hand)
    if player_hand.is_done?
      player_hand.process
      return
    end

    draw_hands
    player_hand.get_action
  end

  def play_dealer_hand
    if dealer_hand.is_blackjack?
      dealer_hand.hide_down_card = false
    end

    if !need_to_play_dealer_hand
      dealer_hand.played = true
      pay_hands
      return
    end

    dealer_hand.hide_down_card = false

    soft_count = DealerHand.get_value(dealer_hand, Hand::Count::Soft)
    hard_count = DealerHand.get_value(dealer_hand, Hand::Count::Hard)
    while soft_count < 18 && hard_count < 17
      shoe.deal_card(dealer_hand)
      soft_count = DealerHand.get_value(dealer_hand, Hand::Count::Soft)
      hard_count = DealerHand.get_value(dealer_hand, Hand::Count::Hard)
    end

    dealer_hand.played = true
    pay_hands
  end

  def need_to_play_dealer_hand
    player_hands.each do |player_hand|
      return true if !(player_hand.is_blackjack? || PlayerHand.is_busted?(player_hand))
    end
    false
  end

  def split_current_hand
    current_hand = player_hands[current_player_hand]

    if !current_hand.can_split?
      draw_hands
      current_hand.get_action
      return
    end

    player_hands << PlayerHand.new(self, current_bet)

    x = player_hands.size - 1
    while x > current_player_hand
      player_hand = player_hands[x - 1].clone
      player_hands[x] = player_hand
      x -= 1
    end

    this_hand = player_hands[current_player_hand]
    split_hand = player_hands[current_player_hand + 1]

    split_hand.cards.clear
    card = this_hand.cards.last
    split_hand.cards << card
    this_hand.cards.pop
    shoe.deal_card(this_hand)

    if this_hand.is_done?
      this_hand.process
      return
    end

    draw_hands
    player_hands[current_player_hand].get_action
  end

  def ask_insurance
    puts " Insurance?  (Y) Yes  (N) No"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'y'
        br = true
        insure_hand
      when 'n'
        br = true
        no_insurance
      else
        br = true
        clear
        draw_hands
        ask_insurance
      end

      break if br
    end
  end

  def insure_hand
    player_hand = player_hands[current_player_hand]

    player_hand.bet /= 2
    player_hand.played = true
    player_hand.paid = true
    player_hand.status = Hand::Status::Lost

    @money -= player_hand.bet
    draw_hands
    bet_options
  end

  def no_insurance
    if dealer_hand.is_blackjack?
      dealer_hand.hide_down_card = false
      dealer_hand.played = true

      pay_hands
      draw_hands
      bet_options
      return
    end

    player_hand = player_hands[current_player_hand]
    if player_hand.is_done?
      play_dealer_hand
      draw_hands
      bet_options
      return
    end

    draw_hands
    player_hand.get_action
  end

  def normalize_current_bet
    if @current_bet < MIN_BET
      @current_bet = MIN_BET
    end

    if @current_bet > MAX_BET
      @current_bet = MAX_BET
    end

    if @current_bet > @money
      @current_bet = @money
    end
  end

  def pay_hands
    dhv = DealerHand.get_value(dealer_hand, Hand::Count::Soft)
    dhb = DealerHand.is_busted?(dealer_hand)

    player_hands.each do |player_hand|
      next if player_hand.paid

      player_hand.paid = true
      phv = PlayerHand.get_value(player_hand, Hand::Count::Soft)

      if dhb || phv > dhv
        if player_hand.is_blackjack?
          player_hand.bet *= 1.5
        end

        @money += player_hand.bet
        player_hand.status = Hand::Status::Won

      elsif phv < dhv
        @money -= player_hand.bet
        player_hand.status = Hand::Status::Lost

      else
        player_hand.status = Hand::Status::Push
      end
    end

    normalize_current_bet
    save_game
  end

  def bet_options
    puts " (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'd'
        br = true
        deal_new_hand
      when 'b'
        br = true
        get_new_bet
      when 'o'
        br = true
        game_options
      when 'q'
        br = true
        @quitting = true
        clear
      else
        br = true
        clear
        draw_hands
        bet_options
      end

      break if br
    end
  end

  def get_new_bet
    clear
    draw_hands

    puts " Current Bet: #{Game.format_money(current_bet)}"
    print " Enter New Bet: $"

    begin
      @current_bet = gets.to_s.to_f * 100.0
    rescue ArgumentError
      @current_bet = MIN_BET
    end

    normalize_current_bet

    deal_new_hand
  end

  def game_options
    clear
    draw_hands

    puts " (N) Number of Decks  (T) Deck Type  (F) Face Type  (B) Back"

    br = false
    while true
      case STDIN.raw &.read_char
      when 'n'
        br = true
        get_new_num_decks
      when 't'
        br = true
        get_new_deck_type
      when 'f'
        br = true
        get_new_face_type
      when 'b'
        br = true
        clear
        draw_hands
        bet_options
      else
        br = true
        clear
        draw_hands
        game_options
      end

      break if br
    end
  end

  def get_new_num_decks
    clear
    draw_hands

    puts " Number Of Decks: #{num_decks}"
    print " Enter New Number Of Decks: "

    begin
      new_num_decks = (STDIN.raw &.read_char).to_s.to_i
    rescue
      new_num_decks = num_decks
    end

    new_num_decks = 1 if new_num_decks < 1
    new_num_decks = 8 if new_num_decks > 8
    @num_decks = new_num_decks

    game_options
  end

  def get_new_deck_type
    clear
    draw_hands

    puts " (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights"

    br = false
    while true
      case STDIN.raw &.read_char
      when '1'
        br = true
        @deck_type = 1
        shoe.new_regular
      when '2'
        br = true
        @deck_type = 2
        shoe.new_aces
      when '3'
        br = true
        @deck_type = 3
        shoe.new_jacks
      when '4'
        br = true
        @deck_type = 4
        shoe.new_aces_jacks
      when '5'
        br = true
        @deck_type = 5
        shoe.new_sevens
      when '6'
        br = true
        @deck_type = 6
        shoe.new_eights
      else
        get_new_deck_type
      end

      if br
        draw_hands
        bet_options
        break
      end
    end
  end

  def get_new_face_type
    clear
    draw_hands

    puts " (1) A♠  (2) 🂡"

    br = false
    while true
      case STDIN.raw &.read_char
      when '1'
        br = true
        @face_type = 1
      when '2'
        br = true
        @face_type = 2
      else
        get_new_face_type
      end

      if br
        draw_hands
        bet_options
        break
      end
    end
  end

  def save_game
    file = "#{num_decks}|#{money}|#{current_bet}|#{deck_type}|#{face_type}"
    File.write SAVE_FILE, file
  end

  def load_game
    begin
      file = File.read SAVE_FILE
    rescue
      file = ""
    end

    a = file.split("|")
    if a.size == 5
      @num_decks = a[0].to_i
      @money = a[1].to_f
      @current_bet = a[2].to_f
      @deck_type = a[3].to_i
      @face_type = a[4].to_i
    end

    if money < MIN_BET
      @money = START_MONEY
      @current_bet = MIN_BET
    end
  end

  def self.format_money(money)
    "$#{sprintf("%.2f", money / 100.0)}"
  end
end
