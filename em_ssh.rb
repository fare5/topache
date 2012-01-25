require 'rubygems'
require 'em-ssh'
require './apache_parser'
require './ascii_ansi'

HOST = configatron.host #'localhost'
USER = configatron.user #'root'
PASSWORD = configatron.pass 

FILE = configatron.file #'/var/log/apache2/access.log'
#FILE = '/home/falkadi/work/pm/maintance/file-tail/ssh_em/access.log'
COMMAND = configatron.command + " #{FILE}" #"tail -f  #{FILE}"

INTERVAL = 1 #second
MAX_HITERS = 4 #set how many "best hiters" show, even if you put 0 u get one position

include AsciiAnsi

EM.run do

  ap = ApacheParser.new

  puts "\e[2J" #clear the screen

  EM.add_periodic_timer(INTERVAL) { puts AsciiAnsi.location(1,1) + "\e[2Khits per secound: "  + ap.avg_per_s.to_s }
  EM.add_periodic_timer(INTERVAL) { puts AsciiAnsi.location(2,1) + "\e[2Khits: #{ap.counter}\t secounds: #{ap.secounds}" }
  EM.add_periodic_timer(INTERVAL+2) { puts AsciiAnsi.location(6,2) + "\e[0J" + ap.best_hiters(MAX_HITERS) }
  
  EM::Ssh.start(HOST, USER, :password => PASSWORD) do |ssh|
#    ssh.exec!('uname -a').tap{|r| puts "\nuname: #{r}"}

    channel = ssh.open_channel do |ch|
      ch.exec COMMAND do |ch, success|
        raise "could not execute command" unless success
        ch.on_data do |c, data|
          res = ap.parse data
          $stdout.print AsciiAnsi.location(4,3) + "\e[2K" + res['%h'] + "\n" if res
#          $stdout.print "\e[2J" + (ap.parse data)['%h'] + "\n"
        end

        ch.on_extended_data do |c, type, data|
          $stderr.print data
        end

        ch.on_close{ puts "dzieki donek!" }
      end
    end

   channel.wait

   ssh.close

#    EM.stop
  end #EM::Ssh.start

end #EM.run do

