require "socket"

server = TCPServer.new 5678

while session = server.accept
  request = session.gets
  p request

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: application/json\r\n" # 2
  session.print "\r\n" # 3
  session.print '{"abc": "def", "ghi": {"a": "1"}}'
  session.close
end