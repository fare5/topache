require 'apachelogregex'
require 'active_support'

class ApacheParser

  attr_reader :counter, :oh, :start, :h_ip_hits, :h_status_hits

  ROUND = 4 #digit round hits pers second

  def initialize
    @format = configatron.log_format #'%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"'
    @counter = 0
    @start = Time.now
    @h_ip_hits = Hash.new(0) #ip => hits
    @h_status_hits = Hash.new(0) #status => hits
    @parser = ApacheLogRegex.new(@format)
    @oh = ActiveSupport::OrderedHash.new
#    @oh_status = ActiveSupport::OrderedHash.new
@h = {}
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
      @h_status_hits[ h['%>s'] ] += 1
      @oh[Time.now.to_f] = h['%h']
#      @oh_status[Time.now.to_f] = h['%s']
    end
    h
  end
  
  def seconds
    (Time.now - @start).round(ROUND)
  end

  def avg_per_s
    ( @counter / (Time.now - @start) ).round(ROUND)
  end
  
  def clear_oh(sec)
  end

end
