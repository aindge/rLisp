{
  :makelist => lambda {|a| 
    z = [a[a.size - 2], a[a.size-1]]
    (3..a.size).each do |i|
      z = [a[a.size - i], z]
    end
    return z
  }
}