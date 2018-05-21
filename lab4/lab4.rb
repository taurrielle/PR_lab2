require 'net/imap'
require 'mail'
require 'pry'
require 'base64'
require 'io/console'
require 'net/smtp'
require 'time'
require 'tlsmail'

puts "Enter your email: "
username = gets.chomp

puts "Enter your password: "
password = STDIN.noecho(&:gets).chomp!

imap = Net::IMAP.new('imap.gmail.com', ssl: true)
imap.login(username, password)
imap.examine('INBOX')
all_emails = imap.search(["ALL"]).size
puts "All messages: #{all_emails}\n\n"
puts "Unread messages: #{imap.search(["NOT", "SEEN"]).size}\n\n"

puts "Nr of email to fetch: "
fetch_nr = gets.chomp

all_emails.downto(all_emails - fetch_nr.to_i) do |message_id|
  envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
  subject = Mail::Encodings.unquote_and_convert_to( envelope.subject, 'utf-8' )
  puts "From: #{envelope.from[0].name}\n"
  puts "Subject: #{subject}\n"
  puts "Date: #{envelope.date}\n\n"
end


puts "To email: "
to_email = gets.chomp
puts "Subject: "
subject = gets.chomp
puts "Your message"
content = gets.chomp

content = <<EOF
From: #{username}
To: #{to_email}
Subject: #{subject}
Date: #{Time.now.rfc2822}
#{content}
EOF

Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', username, password, :login) do |smtp|
  smtp.send_message content, username, to_email
end


