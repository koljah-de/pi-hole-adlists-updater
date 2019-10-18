# pi-hole-adlists-updater
**This automatically updates your local and online pi-hole adlists. Written in bash. Uses systemd.**

## Note

Please keep in mind, that this script backups and **overwrites** your existing */etc/pihole/adlists.list*. Configure *pi-hole-adlists.sh* properly to add your own sources of adlists.

## Install

### Install with install.sh

Run with sudo (download zip archive):
```
cd /tmp && wget -q https://github.com/koljah-de/pi-hole-adlists-updater/archive/master.zip -O pi-hole-adlists-updater-master.zip && unzip -q pi-hole-adlists-updater-master.zip && cd pi-hole-adlists-updater-master && sudo ./install.sh && cd .. && rm -r pi-hole-adlists-updater-master*
```

Or run with sudo (clone git repository):
```
cd /tmp && git clone https://github.com/koljah-de/pi-hole-adlists-updater.git && cd pi-hole-adlists-updater && sudo ./install.sh && cd .. && rm -rf pi-hole-adlists-updater
```

Or download the sources, unzip them, change to the directory which you have just unzipped and run *install.sh* as root:
```
wget https://github.com/koljah-de/pi-hole-adlists-updater/archive/master.zip -O pi-hole-adlists-updater-master.zip
unzip pi-hole-adlists-updater-master.zip
cd pi-hole-adlists-updater-master
sudo ./install.sh
```

Or clone the git repository, change to the directory which you have just cloned and run *install.sh* as root:
```
git clone git@github.com:koljah-de/pi-hole-adlists-updater.git
cd pi-hole-adlists-updater
sudo ./install.sh
```

### Install by hand

Download the sources, unzip them and change to the directory which you have just unzipped:
```
wget https://github.com/koljah-de/pi-hole-adlists-updater/archive/master.zip -O pi-hole-adlists-updater-master.zip
unzip pi-hole-adlists-updater-master.zip
cd pi-hole-adlists-updater-master
```

Or clone the git repository and change to the directory which you have just cloned:
```
git clone git@github.com:koljah-de/pi-hole-adlists-updater.git
cd pi-hole-adlists-updater
```

Copy the files as root and set the right permissions:
```
cp adlists.lists.default /etc/pihole/
chown $(stat -c "%U:%G" /etc/pihole/) /etc/pihole/adlists.list.default
cp pi-hole-adlists.sh /usr/local/sbin/
cp pi-hole-adlists.service /etc/systemd/system/
cp pi-hole-adlists.timer /etc/systemd/system/
```

Enable and start the timer:
```
systemctl enable pi-hole-adlists.timer
systemctl start pi-hole-adlists.timer
```

## Edit the adlists

You may want to edit or add local adlists files. To do this edit *pi-hole-adlists.sh*:
```
# Add further local adlists files here. Use this method:
# Beware: Do not add empty entries to the array!
# This script overwrites: adlists.list adlists.list.old
# adlists_local+=( "new_local_adlists_file" )
adlists_local=( "/etc/pihole/adlists.list.default" )
adlists_local+=( "path_to_adlists_file/adlists.file" )
```

You may want to edit or add online adlists. To do this edit *pi-hole-adlists.sh*:
```
# Add further adlists here. Use this method:
# Beware: Do not add empty entries to the array!
# adlists_online+=( "new_online_adlists" )
adlists_online=( "https://v.firebog.net/hosts/lists.php?type=nocross" )
adlists_online+=( "https://more_online_adlists" )
```

## Adjust the time the script runs

*By default, the adlists are updated every Sunday at 0:00. The timer should run before your gravity is updated. Mine will be updated on Mondays at 0:00.*

To change the update time of adlists, edit *pi-hole-adlists.timer*:
```
OnCalendar=Sun *-*-* 0:00:00
```

After this you must run:
```
systemctl daemon-reload
```

## Adjust the user who runs the script

*You don't need to do this. The script will set the right owner and group for the adlists.list files.*

If pihole-FTL is running as another user than root and owns /etc/pihole, you can edit the following line in *pi-hole-adlists.service*:
```
User=user_that_runs_pihole-FTL_and_owns_directory
```

You should then move `pi-hole-adlists.sh` to `/usr/local/bin` and edit the following line in *pi-hole-adlists.service*:
```
ExecStart=/bin/bash /usr/local/bin/pi-hole-adlists.sh
```

After this you must run:
```
systemctl daemon-reload
```

## Uninstall

### Uninstall with uninstall.sh

Change to the pi-hole-adlists-updater directory and run *uninstall.sh* as root:
```
sudo ./uninstall.sh
```

### Uninstall by hand

Run as root:
```
systemctl disable pi-hole-adlists.timer
systemctl stop pi-hole-adlists.timer
rm /etc/systemd/system/pi-hole-adlists.timer
rm /etc/systemd/system/pi-hole-adlists.service
rm /usr/local/sbin/pi-hole-adlists.sh
```
