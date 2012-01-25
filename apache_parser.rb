require 'apachelogregex'

class ApacheParser

  attr_reader :counter

  ROUND = 4 #digit round hits pers second

  def initialize
    @format = Settings[:format]#'%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"'
    @counter = 0
    @start = Time.now
    @h_ip_hits = Hash.new(0) #ip => hits
#    @h_ip_fifo = {}
#    @a_hits_fifo = []
    @parser = ApacheLogRegex.new(@format)
  end

  def parse(line)
    @counter += 1  #TODO counts everythuing .. even not matched
#    parser = ApacheLogRegex.new(@format)
    if Settings.key?(:preformat) && Settings[:preformat]
      puts line = $1 if line.match(/#{Settings[:preformat]}/)
    end
    h = @parser.parse(line)
    @h_ip_hits[ h['%h'] ] += 1 if h
#    @a_hits_fifo << Time.now.to_i
    h
  end
  
  def secounds
    (Time.now - @start).round(ROUND)
  end

  def avg_per_s
    ( @counter / (Time.now - @start) ).round(ROUND)
  end
  
  def best_hiters(number)
    str = "no\tip\t\thits\thits/s\n"
    @h_ip_hits.sort{|a,b| a[1] <=> b[1]}.reverse.each_with_index do |arr, nr|
      str << "[#{nr+1}] \t #{arr[0]} #{arr[0].length < 8?"\t" : ""}\t #{arr[1]}\t#{( arr[1]/(Time.now - @start) ).round(ROUND)}\n"
      break if nr > number - 2 #at the end with 2, to make one iteration less then with 1 at the beginning of the each_with_index
    end
    str
  end

end
