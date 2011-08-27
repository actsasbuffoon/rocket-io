require "spec/helper/all"

URL = "http://localhost:8081/"
DELAY = 0.25

describe EventMachine::HttpRequest do
  it "should perform a synchronous fetch" do
    EM.synchrony do
      s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nFoo", DELAY)

      r = EventMachine::HttpRequest.new(URL).get
      r.response.should == 'Foo'

      s.stop
      EventMachine.stop
    end
  end

  it "should fire sequential requests" do
    EventMachine.synchrony do
      s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nFoo", DELAY)

      start = now
      order = []
      order.push :get  if EventMachine::HttpRequest.new(URL).get
      order.push :post if EventMachine::HttpRequest.new(URL).post
      order.push :head if EventMachine::HttpRequest.new(URL).head
      order.push :post if EventMachine::HttpRequest.new(URL).delete
      order.push :put  if EventMachine::HttpRequest.new(URL).put

      (now - start.to_f).should be_within(DELAY * order.size * 0.15).of(DELAY * order.size)
      order.should == [:get, :post, :head, :post, :put]

      s.stop
      EventMachine.stop
    end
  end

  it "should fire simultaneous requests via Multi interface" do
    EventMachine.synchrony do
      s = StubServer.new("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nFoo", DELAY)

      start = now

      multi = EventMachine::Synchrony::Multi.new
      multi.add :a, EventMachine::HttpRequest.new(URL).aget
      multi.add :b, EventMachine::HttpRequest.new(URL).apost
      multi.add :c, EventMachine::HttpRequest.new(URL).ahead
      multi.add :d, EventMachine::HttpRequest.new(URL).adelete
      multi.add :e, EventMachine::HttpRequest.new(URL).aput
      res = multi.perform

      (now - start.to_f).should be_within(DELAY * 0.15).of(DELAY)
      res.responses[:callback].size.should == 5
      res.responses[:errback].size.should == 0

      s.stop
      EventMachine.stop
    end
  end
end
