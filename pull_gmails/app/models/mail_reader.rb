# app/models/mail_reader.rb
require 'net/pop'
require 'tmail'
 
class MailReader < ActionMailer::Base
  def self.process(email_str)
    email = TMail::Mail.parse(email_str)
    email.attachments.each do |att|
      #generate randid
      chars = ["A".."Z","a".."z","0".."9"].collect { |r| r.to_a }.join
      randid = (1..8).collect { chars[rand(chars.size)] }.pack("C*")
      filename = att.original_filename.gsub(/\.\w+$/,"_#{randid}"+'\0')

      File.open("#{Rails.root}/tmp/#{filename}", 'w') {|f| f.write(att.gets(nil))}
      `scp #{Rails.root}/tmp/#{filename} mb@sporq.com:/home/mb/menu_bulk/miscCA`
      File.delete("#{Rails.root}/tmp/#{filename}")
    end
  end
 
  def self.check_mail
    logger = RAILS_DEFAULT_LOGGER
 
    logger.info "Checking for emails..."
    Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) #This line raises error if ruby version &lt; 1.8.7
    Net::POP3.start("pop.gmail.com", 995, "sporqmenus@gmail.com", "sporqadm1n") do |pop|
      if pop.mails.empty?
        logger.info "No emails found."
      else
        pop.mails.each do |email|
          begin
            logger.info "Retrieving mail..."
            MailReader.process(email.pop)
            email.delete
          rescue Exception => e
            logger.error "[" + Time.now.to_s + "] " + e.message
          end
        end
      end
    end
    logger.info "Done."
  end
end
