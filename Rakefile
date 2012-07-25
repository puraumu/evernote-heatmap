server_port = 9292
public_dir = "public"

coffee_out = "#{public_dir}/js"
coffee_src = "coffee"

task :server do
  puts "Run Rackup Server"
  rackupPid = Process.spawn("rackup --port #{server_port}")
  coffeePid = Process.spawn("coffee --watch --compile --output #{coffee_out} #{coffee_src}")
  compassPid = Process.spawn("compass watch")
  trap("INT") {
    [compassPid, coffeePid, rackupPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }
  [compassPid, coffeePid, rackupPid].each { |pid| Process.wait(pid) }
end

