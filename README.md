# Z-Push-shared-folders
Add/Remove shared folders in Z-Push Version >= 2.4 Serverside

Currently Tested with RHEL 7 (CentOS 7) and backend kopano.

This Script is currently without defining a device and will add/remove the Folder from ALL devices associated with the username.

It comes without any warranty

Usage:

For Remove:

add_shared_folder.sh "remove" "username" "local-folder name"

example: ./add_shared_folder.sh "remove" "user1" "Calendar - Meetingroom 1"


For Adding:

add_shared_folder.sh "add"  "username" "local-folder name" "from store/username" "typ"

example: ./add_shared_folder.sh "add" "user1" "calendar - Meetingroom 1" "user-meetingroom1" "calendar"

Possible Values for typ:
'email', 'calendar', 'contact', 'task', 'note'
