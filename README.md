# systemd_101

Motivation behind this project is to understand how systemd works for different cases.

While I was trying to configure my service's systemd unit file, I came across a strange(?) behavior: When I issue `sudo systemctl start myservice` command, the service stopped immediately after it had started. I figured out it happened because `ExecStop` was executed after `ExecStart` had been executed. I searched on Google and saw other people questioning why that happened. Mostly, the answers did not work for me. But following articles were very helpful:
* [freedesktop.org: systemd.service — Service unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
* [On-demand activation of Docker containers with systemd](https://developer.atlassian.com/blog/2015/03/docker-systemd-socket-activation/)

I noticed that the strange(?) behavior (automatic execution of `ExecStop` immediately after `ExecStart` has been executed) had close relation with;
* whether the process is foreground or background process AND
* `Type` and `RemainAfterExit` parameters of unit file

Then I decided to create a sample project to better understand how systemd behaves. 

If you would like to run these tests;

* Copy files under `etc/systemd/system` and `usr/local/bin` directories to your host's relevant directories.
* Execute `chmod +x /usr/local/bin*` 
* Execute `sudo systemctl enable mytestservice` 

For each test you would like to try;

* Update `/etc/systemd/system/mytestservice.service` file according to the test. For example;  
    * for Test 1:

    ```
    [Unit]
    Description=My Test Service

    [Service]
    ExecStart=/bin/bash /usr/local/bin/startup.sh case1
    ExecStop=/bin/bash /usr/local/bin/shutdown.sh case1
    #Type=oneshot
    #RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    ```

    * for Test 7: 
    ```
    [Unit]
    Description=My Test Service

    [Service]
    ExecStart=/bin/bash /usr/local/bin/startup.sh case2
    ExecStop=/bin/bash /usr/local/bin/shutdown.sh case2
    Type=forking
    #RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    ```

* Execute `sudo systemctl daemon-reload` 

Now you can execute `sudo systemctl start mytestservice`,  `sudo systemctl stop mytestservice`, `sudo systemctl status mytestservice` etc.

Here are the results of my own tests.


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
