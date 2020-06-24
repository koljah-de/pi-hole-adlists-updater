#!/usr/bin/env bash

# Add further local adlists files here. Use this method:
# Beware: Do not add empty entries to the array!
# adlists_local+=( "new_local_adlists_file" )
adlists_local=( "/etc/pihole/adlists.list.default" )

# Add further online adlists here. Use this method:
# Beware: Do not add empty entries to the array!
# adlists_online+=( "new_online_adlists" )
adlists_online=( "https://v.firebog.net/hosts/lists.php?type=nocross" )

# This stores the adlists
adlists_list=''

# Pi-hole databse
database="/etc/pihole/gravity.db"

# Check database access rights
if ! [[ -r ${database} && -w ${database} ]]; then
  echo "ERROR! Can't access database. Database does not exist or has wrong permissions."
  echo "       Run this script as root or as the user who owns ${database}."
  exit 1
fi

# Get adlists from database
adlists_table="$(sqlite3 ${database} "SELECT address FROM adlist ORDER BY id ASC;")"

# Increment the max id from the adlist table by 1
id=$(($(sqlite3 ${database} "SELECT MAX(id) FROM adlist;")+1))

# This value changes if the database has been modified.
table_changed=0

# Add local adlists files
for ((i=0; i<${#adlists_local[@]}; i++)); do
  if [ -f ${adlists_local[$i]} ]; then
    if [ $((${#adlists_local[@]}-$i)) -gt 1 ] || [ ${#adlists_online[@]} -gt 0 ]; then
      adlists_list+="$(cat ${adlists_local[$i]})\n"
    else
      adlists_list+="$(cat ${adlists_local[$i]})"
    fi
  else
    echo "ERROR! Can't get local adlists:"
    echo "       ${adlists_local[$i]}"
    exit 1
  fi
done

# Get the online adlists
for ((i=0; i<${#adlists_online[@]}; i++)); do
  if [ $((${#adlists_online[@]}-$i)) -gt 1 ]; then
    adlists_list+="$(curl -sL ${adlists_online[$i]})\n"
  else
    adlists_list+="$(curl -sL ${adlists_online[$i]})"
  fi
  if [ $? -ne 0 ]; then
    echo "ERROR! Can't get online adlists:"
    echo "       ${adlists_online[$i]}"
    exit 1
  fi
done

# Cleanup adlists list: remove comments, doubles, empty lines and sort adlists
adlists_list="$(echo -e "$adlists_list" | sed -r '/^[[:blank:]]*#/d;/^\s*$/d')"
adlists_list="$(echo -e "$adlists_list" | sort -u)"

# Add new adlists to database
IFS=$'\n'
for url in $(echo -e "${adlists_list}"); do
  if ! $(echo -e "${adlists_table}" | grep -q "^${url}$"); then
    sqlite3 ${database} "INSERT INTO adlist (id,address,enabled,date_added,date_modified,comment) VALUES (${id},\"${url}\",1,$(date +%s),$(date +%s),\"$(date "+%Y-%m-%d"): Added by Pi-hole Adlists Updater\");"
    ((id+=1))
    table_changed=1
  fi
done

# Disable adlists that no longer exist in any list.
# Adlists that were added manually via AdminLTE are automatically disabled.
# You have to add them to a local adlists file or add them via AdminLTE and comment this part.
IFS=$'\n'
for url in $(echo -e "${adlists_table}"); do
  if ! $(echo -e "${adlists_list}" | grep -q "^${url}$") && [ "$(sqlite3 ${database} "SELECT enabled FROM adlist WHERE address = \"${url}\";")" = "1" ]; then
    sqlite3 ${database} "UPDATE adlist SET enabled = 0 WHERE address = \"${url}\";"
    table_changed=1
  fi
done

# Uncomment 'pihole -g' if you want to update the gravity list, every time the adlists have changed.
if [ "${table_changed}" = 0 ]; then
  echo "Adlists are already up to date."
else
  echo "Adlists have been updated."
#  pihole -g
fi

exit 0
