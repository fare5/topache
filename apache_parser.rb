require 'apachelogregex'
require 'active_support'

class ApacheParser

  attr_reader :counter, :oh

  ROUND = 4 #digit round hits pers second
  NUMBER_S1 = 4

  def initialize
    @format = configatron.log_format #'%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"'
    @counter = 0
    @start = Time.now
    @h_ip_hits = Hash.new(0) #ip => hits
    @parser = ApacheLogRegex.new(@format)
    @h_ip_hits_1s = Hash.new(0) #ip => hits in 1second only matched hits
    @str_s1 = 'no data for 1 second'
#    @h_ip_hits_5s = Hash.new(0) #ip => hits in 5second only matched hits
#    @str_s5 = 'no data for 5 second'
#    @h_ip_fifo = {}
#    @a_hits_fifo = []
    @oh = ActiveSupport::OrderedHash.new
  end

  def parse(line)
    @counter += 1  #TODO counts everythuing .. even not matched
#    parser = ApacheLogRegex.new(@format)
    unless configatron.preformat.nil?
      line = $1 if line.match(/#{configatron.preformat}/)
    end
    h = @parser.parse(line)
    if h
      @h_ip_hits[ h['%h'] ] += 1
      ip_hits_1s( h['%h'] )
      @oh[Time.now.to_f] = h['%h']
#      ip_hits_5s( h['%h'] )
#      @a_hits_fifo << Time.now.to_i
    end
    h
  end
  
  def seconds
    (Time.now - @start).round(ROUND)
  end

  def avg_per_s
    ( @counter / (Time.now - @start) ).round(ROUND)
  end
  
  def best_hiters(number)
    str = "no\tip\t\thits\thits/s\n"
    @h_ip_hits.sort{|a,b| b[1] <=> a[1]}.each_with_index do |arr, nr|
      str << "[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\t#{( arr[1]/(Time.now - @start) ).round(ROUND)}\n"
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end
    str
  end

  def hits_per_sec(sec)

    @oh.reverse_each do |time, ip|
      return "no data for #{sec} second..." if Time.now.to_f - time > sec
      break
    end

    start = nil
    count = 0

    @oh.reverse_each do |time, ip|
      start ||= time
#      puts "time:#{Time.at(time)}, now:#{Time.now}, start #{Time.at(start)}"
      break if Time.now.to_f - time > sec
#      puts oh.reverse_each{ |nr, time| st||=time; puts time, nr, st-time, "st #{st}"; break if st-time > 4}
      count += 1
    end

    "#{sec}s -> #{count.fdiv(sec).round(ROUND)}/s\thits #{count}, second(s) #{sec}"

  end

  def best_hiters_per_sec(sec, number)

    start = nil
    now = Time.now.to_f
    h_ip_hits_per_sec = Hash.new(0)

    @oh.reverse_each do |time, ip|
      return "no data for #{sec} second..." if now - time > sec
      break
    end

    @oh.reverse_each do |time, ip|
      start ||= time
#      puts "time:#{Time.at(time)}, now:#{Time.now}, start #{Time.at(start)}"
      break if now - time > sec
#      puts oh.reverse_each{ |nr, time| st||=time; puts time, nr, st-time, "st #{st}"; break if st-time > 4}
      h_ip_hits_per_sec[ip] += 1
    end

    #TODO use best_hiters(number), add parameter hash?
    str = "#{sec}s\tno\tip\t\thits\thits/s\n"
    h_ip_hits_per_sec.sort{|a,b| b[1] <=> a[1]}.each_with_index do |arr, nr|
      str << "\t[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\t#{arr[1].fdiv(sec).round(ROUND)}\n"
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end
    str

  end


  def clear_oh(sec)
  end


  def ip_hits_1s( host = nil )#parametr ile sekund?
    now = Time.now
    @s1_start ||= now
    if now - @s1_start > 1 then
      @s1_start = now

      #TODO wygenerowanie strina jak w best_hiters + fukcja do tego
        @str_s1 = "no\tip\t\thits\n"
        @h_ip_hits_1s.sort{|a,b| a[1] <=> b[1]}.reverse.each_with_index do |arr, nr|
          @str_s1 << "[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\n"
          break if nr > NUMBER_S1 - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
        end #unless @h_ip_hits_1s.empty
      @h_ip_hits_1s.clear
    end
    @h_ip_hits_1s[host] += 1 if host #host = nil if function used to refresh h_ip_hits_1s
  end
  
  def str_s1
    ip_hits_1s
    #@h_ip_hits_1s.empty? 
    @str_s1.lines.count > 1 ? @str_s1 : "no data for 1 second..."
  end

end
