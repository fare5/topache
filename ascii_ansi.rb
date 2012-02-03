module AsciiAnsi
  public 

  FBLACK = "\e30m"
  BBLACK = "\e40m"
  FRED = "\e[31m"
  BRED = "\e[41m"
  FGREEN = "\e[32m"
  BGREEN = "\e[42m"
  FYELLOW = "\e[33m"
  BYELLOW = "\e[43m"
  FWHITE = "\e[37m"
  BWHITE = "\e47m"
  FBLUE = "\e[34m"
  BBLUE = "\e[44m"
  
  def location(line, column)
    "\e[#{line};#{column}H"  
  end
  

end
