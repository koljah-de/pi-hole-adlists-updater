#!/usr/bin/env bash

# Add further local adlists files here. Use this method:
# Beware: Do not add empty entries to the array!
# This script overwrites: adlists.list adlists.list.old
# adlists_local+=( "new_local_adlists_file" )
adlists_local=( "/etc/pihole/adlists.list.default" )

# Add further online adlists here. Use this method:
# Beware: Do not add empty entries to the array!
# adlists_online+=( "new_online_adlists" )
adlists_online=( "https://v.firebog.net/hosts/lists.php?type=nocross" )

adlists_list=""

# Add local adlists files.
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

# Get the online adlists.
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

# Sort adlists and remove doubles and empty lines
echo -e "$adlists_list" | sort -u > /tmp/adlists.list.new
sed -ir '/^\s*$/d' /tmp/adlists.list.new

# Compare the old with the new one. If something has changed, backup the old one
# and use the new one.
if [ -f /etc/pihole/adlists.list ]; then
  if $(cmp -s /tmp/adlists.list.new /etc/pihole/adlists.list); then
    echo "Adlists are already up to date."
    rm /tmp/adlists.list.new
  else
    echo "Adlists have been updated."
    cp /etc/pihole/adlists.list /etc/pihole/adlists.list.old
    mv /tmp/adlists.list.new /etc/pihole/adlists.list
# Uncomment this if you want to update the gravity list, every time the adlists
# have changed.
#    chown $(stat -c "%U:%G" /etc/pihole/) /etc/pihole/adlists.list
#    pihole -g
  fi
elif [ -d /etc/pihole ]; then
  echo "Adlists have been updated."
  mv /tmp/adlists.list.new /etc/pihole/adlists.list
# Uncomment this if you want to update the gravity list, every time the adlists
# have changed.
#  chown $(stat -c "%U:%G" /etc/pihole/) /etc/pihole/adlists.list
#  pihole -g
fi

# Set the right user and group for the adlists.
chown $(stat -c "%U:%G" /etc/pihole/) /etc/pihole/adlists.list*

exit 0
