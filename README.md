# Z-Push-shared-folders
Add/Remove shared folders serverside in Z-Push Version >= 2.4 

Currently Tested with RHEL 7 (CentOS 7.4) and backend kopano.

############################################################################################  
FEEL FREE TO CREATE A WEBAPP-PLUGIN AND REPORT TO KOPANO-FORUM: https://forum.kopano.io/  
############################################################################################  

---It comes without any warranty---

changes:  
Added choice which device should get this folder!  
Added VAR to define if spaces will be masked (needed on some dists)  

 - Usage:

    -  For Remove:

    add_shared_folder.sh "remove" "username" 

    example:   ./add_shared_folder.sh "remove" "user1"   -   the script will ask you for the folder


      -  For Adding:

    add_shared_folder.sh "add"  "username" "local-folder name" "from store/username" "typ"

    example:   ./add_shared_folder.sh "add" "user1" "calendar - Meetingroom 1" "user-meetingroom1" "calendar"

Possible Values for typ:
'email', 'calendar', 'contact', 'task', 'note'
