require 'active_support/core_ext/object'

class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    rank = rank.to_s.upcase
    suit.upcase!
    raise "Invalid rank: #{rank}" unless rank.in?(self.class.ranks)
    raise "Invalid suit: #{suit}" unless suit.in?(self.class.suits)

    @rank = rank
    @suit = suit
  end

  def rank_as_i
    self.class.ranks.index(@rank) + 2
  end

  def self.suits
    [ 'H', 'S', 'C', 'D' ]
  end

  def self.ranks
    [ '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' ]
  end
end