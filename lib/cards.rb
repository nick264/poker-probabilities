class Cards
  def self.from_a(array)
    retval = []
    array.each do |a|
      retval << Card.new(a[0..-2],a[-1])
    end

    retval
  end
end