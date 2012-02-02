require 'highline/import'	#to get password without echo
require 'getoptlong'
require 'configatron'

configatron.set_default(:host, 'localhost' )
configatron.set_default(:user, 'root' )
configatron.set_default(:log_format, '%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"' )
#configatron.set_default(:preformat, '')
configatron.set_default(:file, '/var/log/apache2/access.log') #'/home/falkadi/work/pm/maintance/file-tail/ssh_em/ch_access.log'
configatron.set_default(:command, 'tail -f -n 1')
configatron.set_default(:password, true)

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--host', '-H', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--user', '-u', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--log_format', '-F', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--preformat', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--file', '-f', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--command', '-c', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--password', '-P', GetoptLong::NO_ARGUMENT ]
			#GetoptLong::OPTIONAL_ARGUMENT 
)

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF #TODO erb with showing defaults form configatron
ruby topache [OPTION]

-h, --help:
   show this help

--host name, -h name:
   hostname to connect. default - localhost

--user name, -u name:
   username to log as. default - root 

--log_format f, -F f:
   format apache logs. default - %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\" combined

--preformat pf, -p pf:
   regular expr esion used to exclude any prefix from apache log line (e.g. if logsys add any prefix)

--file f, -f f:
   path to logfile. default - /var/log/apache2/access.log'

--command c, -c c:
   should it be in the commandline options?

--password, -P:
   boolean flag, if present you will be asked for password to log at --host as --user
      EOF
    when '--host'
      configatron.host = arg
    when '--user'
      configatron.user = arg
    when '--log_format'
      configatron.log_format = arg
    when '--preformat'
      configatron.preformat = arg
    when '--file'
      configatron.file = arg
    when '--command'
      configatron.command = arg
    when '--password'
      configatron.password = true

  end
end

puts configatron.inspect
puts configatron.log_format

( configatron.pass = ask("Enter password: ") {|q| q.echo = false} ) unless configatron.password.nil?

puts configatron.inspect

require './em_ssh'
