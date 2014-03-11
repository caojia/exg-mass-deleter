require 'net/imap'

puts <<USAGE
Usage: ruby ./mail-cleaner username password mailbox
USAGE

puts ""

username = ARGV[0]
password = ARGV[1]
address = 'exg5.exghost.com'
port = 993

KEEP_DAYS = 7
SLICE_SIZE = 1000

mailbox = ARGV[2]
if mailbox.nil? || mailbox.length == 0
  puts "please enter a valid mailbox"
  exit -1
end
until_date = (Time.now - KEEP_DAYS * 24 * 3600).strftime('%d-%b-%Y')

imap = Net::IMAP.new(address, port, true, nil, false)

count = 0
begin
  imap.login(username, password)
  puts "logged in"
  imap.select(mailbox)
  puts "select #{mailbox}"
  uids = imap.uid_search("BEFORE #{until_date}")
  puts "searched BEFORE #{until_date}"
  total_count = uids.size
  puts "total messages to be deleted #{total_count}"
  uids.each_slice(SLICE_SIZE) do |ids|
    imap.uid_store(ids, "+FLAGS", [Net::IMAP::DELETED])
    count += ids.length
    imap.expunge
    puts "deleted #{count}/#{total_count}.." 
  end
ensure
  imap.disconnect
end

