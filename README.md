# systemd_101
Sample unit files to understand how systemd works for different cases.


| Test | Case | Type | RemainAfterExit | Result |
| ---- | ---- | ---- | --------------- | ------------- |
| 1 | case1 | Not defined | Not defined | <ul><li>`sudo systemctl start mytestservice`: ExecStop and so shutdown.sh was not executed.</li><li>`sudo systemctl status mytestservice`: active (running)</li><li>`sudo systemctl stop mytestservice`: ExecStop has been executed.</li><li>`sudo systemctl status mytestservice`: inactive (dead)</li></ul> |
| 2 | case1 | oneshot | Not defined | <ul><li>`sudo systemctl start mytestservice`: Blocked(needed to Ctrl+C to break). ExecStop and so shutdown.sh was not executed.</li><li>Ctrl+C: Process is still running.</li><li>`sudo systemctl status mytestservice`: activating (start)</li><li>`sudo systemctl stop mytestservice`: ExecStop was not executed. Service's process has been killed.</li><li>`sudo systemctl status mytestservice`: inactive (dead)</li></ul> |
| 3 | case1 | forking | Not defined |<ul><li>`sudo systemctl start mytestservice`: Blocked(needed to Ctrl+C to break). ExecStop and so shutdown.sh was not executed.</li><li>Ctrl+C: Process is still running.</li><li>`sudo systemctl status mytestservice`: activating (start)</li><li>If the service is not stopped in 30 seconds, starting operation is timed out and terminated. In that case ExecStop is not executed.</li><li>If the service is stopped in 30 seconds by invoking `sudo systemctl stop mytestservice`: ExecStop was not executed. Service's process has been killed.</li><li>"sudo systemctl status mytestservice": inactive (dead)</li></ul>|
| 4 | case1 | oneshot | RemainAfterExit=yes  | Same as Test 2 |
| 5 | case2 | Not defined | Not defined | <ul><li>`sudo systemctl start mytestservice`: ExecStop and so shutdown.sh was executed.</li><li>`sudo systemctl status mytestservice`: inactive (dead)</li></ul>|
| 6 | case2 | oneshot | Not defined | Same as Test 6 |
| 7 | case2 | forking | Not defined | Same as Test 1 |
| 8 | case2 | Not defined | RemainAfterExit=yes |<ul><li>`sudo systemctl start mytestservice`: ExecStop and so shutdown.sh was not executed.</li><li>`sudo systemctl status mytestservice`: active (exited)</li><li>`sudo systemctl stop mytestservice`: ExecStop has been executed.</li><li>`sudo systemctl status mytestservice`: inactive (dead)</li></ul>|
| 9 | case2 | oneshot | RemainAfterExit=yes | Same as Test 8 |
