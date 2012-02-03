class TopacheView

  include AsciiAnsi

  ROUND = 4

  def initialize (ap)
    @ap = ap
  end

  def refresh
    puts "\e[2J" #clear the screen
    printf AsciiAnsi.location(1,1) + "\e[2Khits per second:#{FYELLOW}%12.6f#{FWHITE} ", @ap.avg_per_s
    printf AsciiAnsi.location(2,1) + "\e[2Khits:%- 14d seconds:%- 10d ", @ap.counter, @ap.seconds
    hits_per_sec(1, 3, 2) #sec, line, column  #TODO where this parameter
    hits_per_sec(6, 5, 2) #TODO where this parameter
    best_hiters(6, 8, 2)

    best_hiters_per_sec(6, 4, 20, 2) #sec, number, line, column
    numbers_of_status(5, 32, 2)

  end

  def best_hiters_per_sec(sec, number, line, column)
    number = number > 10 ? 10:number

    start = nil
    now = Time.now.to_f
    h_ip_hits_per_sec = Hash.new(0)

    str = AsciiAnsi.location(line, column) + "#{FGREEN} ### >> best hiters from last #{sec}sec << #{FWHITE}\n"   #\e[#{line};#{line+9}r" #window
    str += "#{FBLUE} no    ip                hits    hits/s#{FWHITE}\n"
    puts str

    @ap.oh.reverse_each do |time, ip|
      (puts str + "no data for #{sec} second..."; return) if now - time > sec
      break
    end

    @ap.oh.reverse_each do |time, ip|
      start ||= time
#      puts "time:#{Time.at(time)}, now:#{Time.now}, start #{Time.at(start)}"
      break if now - time > sec
      h_ip_hits_per_sec[ip] += 1
    end

    h_ip_hits_per_sec.sort{|a,b| b[1] <=> a[1]}.each_with_index do |arr, nr|
      printf"#{AsciiAnsi.location(line + nr + 2, column)}[%2d]  %-17.15s %-5d #{FYELLOW}%10.6f#{FWHITE} \n", nr+1, arr[0], arr[1], arr[1].fdiv(sec).round(ROUND)
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end

  end

  def numbers_of_status(number, line, column)
    number = number > 10 ? 10:number
    str = AsciiAnsi.location(line, column) + "#{FGREEN} ### >> status from the beginning << #{FWHITE}\n"   #\e[#{line};#{line+9}r" #window
    str += "#{FBLUE} no    status    hits    hits/s#{FWHITE}\n"
    puts str
    @ap.h_status_hits.sort{|a,b| b[1] <=> a[1]}.each_with_index do |arr, nr|
      printf "#{AsciiAnsi.location(line + nr + 2, column)}[%2d]  %-9.5s %-5d #{FYELLOW}%10.6f#{FWHITE} \n" , nr+1, arr[0], arr[1], ( arr[1]/(Time.now - @ap.start) ).round(ROUND)
#      str << "[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\t#{( arr[1]/(Time.now - @start) ).round(ROUND)}\n"
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end
  end


  def hits_per_sec(sec, line, column)

    str = AsciiAnsi.location(line, column) + "#{FGREEN} ### >> hits per sec from last #{sec}sec <<#{FWHITE}\n"

    @ap.oh.reverse_each do |time, ip| #check if there is any data from last #{sec} second
      (puts str + "no data for #{sec} second..."; return) if Time.now.to_f - time > sec
      break
    end

    start = nil
    count = 0

    @ap.oh.reverse_each do |time, ip|
      start ||= time
#      puts "time:#{Time.at(time)}, now:#{Time.now}, start #{Time.at(start)}"
      break if Time.now.to_f - time > sec
      count += 1
    end

    printf "#{str} #{sec}s ->#{FYELLOW}%14.6f/s#{FWHITE} hits #{count}, second(s) #{sec}", count.fdiv(sec).round(ROUND)

  end


  def best_hiters(number, line, column)
    number = number > 10 ? 10:number
    str = AsciiAnsi.location(line, column) + "#{FGREEN} ### >> best hiters from the beginning << #{FWHITE}\n"   #\e[#{line};#{line+9}r" #window
    str += "#{FBLUE} no    ip                hits    hits/s#{FWHITE}\n"
    puts str
    @ap.h_ip_hits.sort{|a,b| b[1] <=> a[1]}.each_with_index do |arr, nr|
      printf "#{AsciiAnsi.location(line + nr + 2, column)}[%2d]  %-17.15s %-5d #{FYELLOW}%10.6f#{FWHITE} \n" , nr+1, arr[0], arr[1], ( arr[1]/(Time.now - @ap.start) ).round(ROUND)
#      str << "[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\t#{( arr[1]/(Time.now - @start) ).round(ROUND)}\n"
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end
  end

end
