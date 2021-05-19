#!/bin/bash
#systemd-alerts.sh
#spmfox@foxwd.com

#Script is designed to be run by systemd, with the first argument being the failed unit.

# This script uses the following commands:
# curl

opt_FriendlyName=""                             # This name will appear in the message
opt_TelegramBotToken=""                         # Token of Telegram Bot
opt_TelegramMessageID=""                        # ID of the Telegram conversation to post the alert to
opt_EmailServer=""				# Email SMTP server
opt_EmailFrom=""				# Email to send from
opt_EmailTo=""					# Email to send to
opt_EmailUser=""				# Username for email
opt_EmailPassword=""				# Password for email

file_AlertEmail="/dev/shm/.systemd-alerts.eml"	# Full path to the file where the email will be temporarily stored

str_FailedUnit=$1
str_FailedUnitJournal=$(journalctl -p3 --no-pager --since '2 min ago' -u $str_FailedUnit)

#Generate messages for Telegram and email
str_GenerateJSON=$(cat <<EOF
{"chat_id": "$opt_TelegramMessageID", "text": "$str_FailedUnitJournal"}
EOF
)

#Telegram message 
if [ -n "$opt_TelegramBotToken" ] && [ -n "$opt_TelegramMessageID" ]; then
 echo "Sending Telegram message."
 str_CurlTelegram=$(curl -s -X POST -H "Content-Type: application/json" -d "$str_GenerateJSON" https://api.telegram.org/bot$opt_TelegramBotToken/sendMessage)
else
 echo "One or both Telegram settings are missing, not sending Telegram message."
fi

#Email message
if [ -n "$opt_EmailServer" ] && [ -n "$opt_EmailFrom" ] && [ -n "$opt_EmailTo" ] && [ -n "$opt_EmailUser" ] && [ -n "$opt_EmailPassword" ]; then
 echo "Sending email."
 echo "From: $opt_EmailFrom" > $file_AlertEmail
 echo "To: $opt_EmailTo" >> $file_AlertEmail
 echo "Subject: $opt_FriendlyName $str_FailedUnit Alert" >> $file_AlertEmail
 echo "" >> $file_AlertEmail
 echo $str_FailedUnitJournal >> $file_AlertEmail
 str_CurlEmail=$(curl -s --ssl-reqd smtp://$opt_EmailServer --mail-from $opt_EmailFrom --mail-rcpt $opt_EmailTo --upload-file $file_AlertEmail --user "$opt_EmailUser":"$opt_EmailPassword")
 rm $file_AlertEmail
else
 echo "One or more email settings are missing, not sending email message."
fi

#Sample systemd file:
###
#alert-notification@.service
#
#[Unit]
#Description=triggering alert for %i
#
#[Service]
#Type=oneshot
#ExecStart=/usr/bin/bash /opt/systemd-alerts.sh %i
###

#Example using this in another systemd unit:
###
#[Unit]
#OnFailure=alert-notification@%i.service
###
