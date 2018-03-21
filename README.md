# Z-Push-shared-folders
Add/Remove shared folders serverside in Z-Push Version >= 2.4 

Currently Tested with RHEL 7 (CentOS 7) and backend kopano.

############################################################################################
FEEL FREE TO CREATE A WEBAPP-PLUGIN AND REPORT TO KOPANO-FORUM: https://forum.kopano.io/
############################################################################################

This Script is currently without defining a device and will add/remove the Folder from ALL devices associated with the username. - It comes without any warranty

 - Usage:

    -  For Remove:

    add_shared_folder.sh "remove" "username" 

    example:   ./add_shared_folder.sh "remove" "user1"   -   the script will ask you for the folder


      -  For Adding:

    add_shared_folder.sh "add"  "username" "local-folder name" "from store/username" "typ"

    example:   ./add_shared_folder.sh "add" "user1" "calendar - Meetingroom 1" "user-meetingroom1" "calendar"

Possible Values for typ:
'email', 'calendar', 'contact', 'task', 'note'
