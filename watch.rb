require 'digest/md5'
require 'bundler'

Bundler.require

if ARGV.size < 2
  abort "Usage: ruby watch.rb [sms number] [url]"
end

number = ARGV[0]
url = ARGV[1]
sleep_ms = (ARGV[2] || 300).to_i

def send_sms(number, message)
  system(
    "curl --silent http://textbelt.com/text -d number=#{number} "\
      "-d 'message=#{message}' > /dev/null"
  )
end

puts "==> Watching #{url}"
send_sms(number, "Watching #{url} for changes...")

previous_hash = nil
previous_body = nil

loop do
  content = HTTParty.get(url).body
  current_hash = Digest::MD5.hexdigest(content)

  print "Checking URL... got hash #{current_hash[0..6]}... "
  print "old hash #{previous_hash[0..6]}... " if previous_hash

  if previous_hash != current_hash && !previous_hash.nil?
    print "sending text... "
    send_sms(number, "Page has changed! #{url}")
  end

  previous_hash = current_hash
  previous_body = content

  puts "sleeping"

  sleep(sleep_ms)
end
