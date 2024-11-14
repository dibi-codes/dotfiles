#!/bin/bash

# Nice to know <https://macos-defaults.com/>

echo "Setup macOS defaults..."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1 # enable airdrop over wired ethernet
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.spaces spans-displays -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "mru-spaces" -bool false # Do NOT reorder Spaces based on most recent use
# defaults write com.apple.dock "static-only" -bool true # Only show opened apps in Dock.
defaults write com.apple.dock "expose-group-apps" -bool true
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false # Disable window animations
defaults write NSGlobalDomain KeyRepeat -int 1 # 
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write NSGlobalDomain AppleHighlightColor -string "0.65098 0.85490 0.58431"
defaults write NSGlobalDomain AppleAccentColor -int 1
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool false
defaults write NSGlobalDomain com.apple.mouse.scaling -float 1.5 # Mouse speed
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.Finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Search current directory by default
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false # 
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # List view
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES
defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
defaults write -g NSWindowShouldDragOnGesture YES
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

killall Dock && killall Finder