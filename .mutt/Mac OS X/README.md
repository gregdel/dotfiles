# Link this file to the launch agent
ln -s ~/dotfiles/.mutt/Mac\ OS\ X/com.offlineimap.plist ~/Library/LaunchAgents/

# Launch it
launchctl load ~/Library/LaunchAgents/com.offlineimap.plist
