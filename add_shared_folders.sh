### Add Shared folder
### new feature in Z-Push >= 2.4.0
### v1.0 by Coffee_is_life
#####  VARS
declare -a logfile=("/var/log/z-push/add_shared_folder.log" "/var/log/z-push/add_shared_folder_error.log")
debug="false" ###  values(true|false)
get_folderid_cmd="$(locate listfolders.php) -l"   ### default location: "/usr/share/z-push/backend/kopano/listfolders.php"
get_user_name="$(which kopano-admin) -l"
add_share_cmd="$(which z-push-admin) -a addshared -u"
remove_share_cmd="$(which z-push-admin) -a removeshared -u"
get_shared_cmd="z-push-admin -a list --shared -u"
default_calendar_flag="4"    ### provided by z-push, 0=none, 1=send-as 4=show reminders 5=combination from 1 and 4
default_mail_flag="1"        ### see above
##### VARS
clear

echo -e "Add or remove Shared Folders\n"
function usage() {
 if [ "$1" = "remove" ]; then
    echo "Usage:
$0 'remove' 'username' 'local folder name'
Example: $0 \"$1\" 'user1' 'Calendar - Meetingroom1'
"
 elif [ "$1" = "add" ]; then
   echo "Usage:
$0 'add' 'username' 'local folder name' 'from Storename/username' 'typ'
Example: $0 'add' 'username' 'Calendar - Meetingroom1' 'user-meetingroom1' 'calendar'
Possible Values for type: 'email', 'calendar', 'contact', 'task', 'note'
"
 else
  echo " Usage:
$0 'aktion' 'username'

"
 fi
quit 1
}

function quit(){
 log "============= ENDE ==============" ERROR
 exit $1
}

function log(){
 if [ "$2" = "DEBUG" ]; then
  if [ "$debug" = "true" ]; then
   echo -e "$(date "+%d.%m.%Y %H:%M:%S") $2: $1" >> ${logfile[0]}
  fi
 elif [ "$2" = "info" ] || [ "$2" = "notice" ]; then
  echo -e "$(date "+%d.%m.%Y %H:%M:%S") $2: $1" >> ${logfile[0]}
 else
   echo -e "$(date "+%d.%m.%Y %H:%M:%S") $2: $1" >> ${logfile[0]}
   echo -e "$(date "+%d.%m.%Y %H:%M:%S") $2: $1" >> ${logfile[1]}
 fi
}

if [[ ${1+x} ]]; then
  if [ "$1" = "add" ]; then
    if [[ -z ${1+x} || -z ${2+x} || -z ${3+x} || -z ${4+x} || -z ${5+x} ]]; then
     usage $1
    fi
  elif [ "$1" = 'remove' ]; then
    if [[ -z ${1+x} || -z ${2+x} ]]; then
     usage $1
    fi
  else
     usage $1
  fi
else
  usage $1
fi

function get_folderid() {
 log "function get_folderid for user $1" DEBUG
 local debug_folderid=$(eval $get_folderid_cmd $1 | grep -B 2 -i $2)
 log "found folders: \n$debug_folderid" DEBUG
 if [ $(echo $debug_folderid |awk -F"Folder ID" '{print NF-1}') = 1  ]; then
  local folderid=$( eval $get_folderid_cmd $1 | grep -B 2 -i $2 | awk -F"ID:" '{print $2}' | awk -F" " '{print $1}' |sed -e 's/\ //g')
  echo $folderid
 elif [ $(echo $debug_folderid |awk -F"Folder ID" '{print NF-1}') = 0 ]; then
   log "No Items with Type $2 found" ERROR
   quit 1
 else
   log "Multiple Items found - starting userchoice" INFO
   id=$(userchoice "$debug_folderid")
   echo $id
 fi
}

function get_user_folderid() {
log "Searching for shared folders given to $1" INFO
log "using this command: $(echo $(echo $get_shared_cmd) \"$1\" | grep -i \"Folder\ name\|Type\|DeviceId\|Device\ type\|Folder\ id\" | sed -e 's/DeviceId/==========================================\nDeviceId/g')" DEBUG
local folders=$(eval $(echo $get_shared_cmd) \"$1\" | grep -i "Folder\ name\|Type\|DeviceId\|Device\ type\|Folder\ id" | sed -e 's/DeviceId/==========================================\nDeviceId/g')
id=$(userchoice "$folders")
echo $id
}

function check_user() {
 log "function check_user for user $1" DEBUG
 local valid=$( eval $get_user_name |grep $1 |wc -l)
 echo $valid
}

function userchoice() {
 i=0
 echo -e "I could find multiple Items, copy the id which you wanna add:\n" >&2
 echo "$1" >&2
 while [ $i = 0 ]; do
 read id
 if [[ $1 =~ .*$id.* ]]; then
  i=1
 else
  echo "ID $id not found!" >&2
 fi
 done
echo $id
}

function do_add_shared() {
 log "Adding Shared Folder to user $1" INFO
 log "To-User: $1 \nFrom-User: $3 \nLocal-Name: $2 \nFolder-ID: $4 \nTyp: $5 \nFlag: $6 " DEBUG
 log "Adding cmd: $add_share_cmd \"$1\" -n \"$2\" -o "$3" -t \"$5\" -f \"$4\" -g=\"$6\"" DEBUG
 eval $(echo $add_share_cmd) \"$1\" -n \"$2\" -o \"$3\" -t \"$5\" -f \"$4\" -g=\"$6\"
}

function do_remove_shared() {
 log "Remove Folderid: $2 from $1" DEBUG
 log "using command $remove_share_cmd \"$1\" -f \"$2\"" DEBUG
 echo "$remove_share_cmd \"$1\" -f \"$2\" - OK? (y/n)"
 read answer
 if [ "$answer" = "y" ]; then
  eval $(echo $remove_share_cmd \"$1\" -f \"$2\")
 else
  quit 1
 fi
}

log "============= BEGIN =============" INFO
valid=$(check_user $2)
if [ "$valid" = "0" ]; then
 log "No user found for $2" ERROR
 quit 1
elif [ "$valid" = "1" ]; then
 log "User Found $2" INFO
else
 log "Found multiple Users for $2 - please provide a unique username" ERROR
 quit 1
fi

if [ "$1" = "add" ]; then
 log "action $1 confirmed" DEBUG

 log "check typ  $5" DEBUG
 case "$5" in
   email) type="SYNC_FOLDER_TYPE_USER_MAIL"; flag=$default_mail_flag
    ;;
   calendar)  type="SYNC_FOLDER_TYPE_USER_APPOINTMENT" flag=$default_calendar_flag
    ;;
   contact) type="SYNC_FOLDER_TYPE_USER_CONTACT"
    ;;
   task) type="SYNC_FOLDER_TYPE_USER_TASK"
    ;;
   note) type="SYNC_FOLDER_TYPE_USER_NOTE"
    ;;
   *)  log "Wrong Type" ERROR; usage $1
    ;;
 esac
 log "Typ confirmed $5=$type" DEBUG

 valid=$(check_user $4)

 if [ "$valid" = "0" ]; then
  log "No user found to retrieve the store from $4" ERROR
  quit 1
 elif [ "$valid" = "1" ]; then
  log "User Found $4, retreiving store" INFO
 else
  log "Found multiple Users for $4 - please provide a unique username" ERROR
  quit 1
 fi
 folderid=$(get_folderid $4 $type)
 log "Found folderid: $folderid" DEBUG
 log "Trying to add Folderid:$folderid to user:$2, named:$3, from user:$4, typ:$type($5)" INFO
 echo "Trying to add Folderid:$folderid to user:$2, named:$3, from user:$4, typ:$type($5)  - OK? (y/n)"
 read answer
 if [ "$answer" = "y" ]; then
  if [ -z $flag ]; then flag=0; fi
  do_add_shared "$2" "$3" "$4" "$folderid" $5 "$flag"
 else
  quit 1
 fi
else
 log "action $1 confirmed" DEBUG
 folderid=$(get_user_folderid "$2" "Type:")
 log "Got Folderid: $folderid"  DEBUG
 do_remove_shared $2 $folderid
fi
log "============= END ==============" info
exit 0
