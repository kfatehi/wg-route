#!/usr/bin/ruby
# basically reason for the script is that the peer might connect from different ips
# and we need to make sure this ip is exempted from being routed through NJ
# because it's trying to connect by way of this server, so this server needs
# to make sure to route its packets back directly to the peer rather than to
# pass it through to the NJ. ok make sense? lets do it
# the caveat here is we need to delete the routes so the way we will do this
# is detect superfluous routes:
def the_business
  deleting = `ip route | grep 'via 136.244.90.1 dev enp1s0'`.split("\n").reject{|a|
    a.include? "default" or a.include? "149.28.238.111" or a.include? "dhcp"
  }.map(&:strip)
  # k now get the ones we wanna add...
  adding = []
  `wg show wg0 endpoints`.split("\n").each do |line|
    a = line.match(/\s(.+):/);
    adding << "#{a[1]} via 136.244.90.1 dev enp1s0" if a and a[1]
  end

  operations = [];

  deleting.each do |aa|
    if adding.include? aa
      # no op
      # operations << "ip route add #{aa}"
    else
      operations << "ip route del #{aa}"
    end
  end

  adding.each do |aa|
    if deleting.include? aa
      # no op
      # operations << "ip route add #{aa}"
    else
      operations << "ip route add #{aa}"
    end
  end

  operations.each do |op|
    puts op
    `#{op}`
  end
end

while true
  the_business
  sleep 1
end
