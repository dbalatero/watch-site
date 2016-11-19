require 'digest/md5'
require 'bundler'

Bundler.require

if ARGV.size < 2
  abort "Usage: ruby watch.rb [sms number] [url] [phrases...]"
end

number = ARGV[0]
url = ARGV[1]
sleep_ms = 300

phrases = ARGV[2..-1]

def send_sms(number, message)
  system(
    "curl --silent http://textbelt.com/text -d number=#{number} "\
      "-d 'message=#{message}' > /dev/null"
  )
end

puts "==> Watching #{url} for #{phrases.inspect}"
send_sms(number, "Watching #{url} for changes...")

loop do
  content = HTTParty.get(url).body
  page = Nokogiri::HTML(content)
  text = page.text

  print "Checking URL... "

  if phrases.any? { |phrase| text.include?(phrase) }
    print "sending text... "
    send_sms(number, "Page has changed! #{url}")
  else
    print "no changes. "
  end

  puts "sleeping"

  sleep(sleep_ms)
end
