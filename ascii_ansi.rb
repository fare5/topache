module AsciiAnsi
  public 
  def location(line, column)
    "\e[#{line};#{column}H"  
  end

end
