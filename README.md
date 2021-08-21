# systemd-alerts

## Why
This is a simple systemd service and script that makes it easy to have failed systemd services email or telegram message you.


## How
We utilize systemd service templates. You simply add the ```OnFailure``` option to a service you care about, and if it fails then the template service will be called which will trigger the script.

## Example
### Paths
Files should be located at the following paths, or you may need to modify the way this works.
```
/opt/systemd-alerts/systemd-alerts.sh
/etc/systemd/system/alert-notification@.service
```

After placing these files in the correct location, just modify a service you care about. Add the following code to the ```[Unit]``` section of the service file.
```
OnFailure=alert-notification@%i.service
```

You do not need to enable the template service.

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