# systemd-alerts

Simple systemd service + script that will send and email or a Telegram message when it is called - useful for service failures.

This can be deployed using Ansible or manually.

## Ansible Installation
```ansible-playbook -i <your host> -e @your_vars.yml deploy.yml```

Be sure to define your variables:
```yaml
system:
  install_directory: "/opt/systemd-alerts"
  friendly_name: "{{ ansible_fqdn }}"
email:
  server: ""
  username: ""
  password: ""
  from: ""
  to: ""
telegram:
  bot_token: ""
  message_id: ""
```


## Manual Installation
1. Copy ```roles/systemd-alerts/files/alert-notification@.service``` -> ```/etc/systemd/system/alert-notification@.service```
2. Create directory ```/opt/systemd-alerts```
3. Copy ```roles/systemd-alerts/files/systemd-alerts.sh``` -> ```/opt/systemd-alerts/systemd-alerts.sh```
4. Edit ```/opt/systemd-alerts/systemd-alerts.sh``` and change the variables at the top of the file


## Usage
After installation, just modify a service you care about. Add the following code to the ```[Unit]``` section of the service file.
```
OnFailure=alert-notification@%i.service
```
You can edit your own service, or ```systemctl edit``` on an existing service to add an override.


## Troubleshooting
1. Check that the template service was run:
    - You can run systemctl status ```alert-notification@<ORIGINAL_SERVICE>.service```
    - If the original service is ```test.service```, then you would run ```systemctl status alert-notification@test.service```
2. If the alert service was triggered, but no email and/or Telegram message was received - you can call the script manually:
    - ```$ bash /opt/systemd-alerts/systemd-alerts.sh test```
3. If the script didn't give any specific errors, you can try to run the script in debug mode and look at what the bash script is doing:
    - ```$ bash -x /opt/systemd-alerts/systemd-alerts.sh test```

The script basically boils down to a ```curl``` command for the email and one for the Telegram message. You may see error output from the ```curl``` commands running in debug.

To get even more data out of the ```curl``` command, you can remove the ```-s``` from each of the ```curl``` commands then run the debug again.
