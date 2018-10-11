### GDB Debugging
This document describes the options available for debugging node using the GNU debugger.

We don't provide the debuginfo package, which contains the symbols required for debugging, as this would make our runtime image about 480MB larger. On systems where root access is allowed then the debuinfo package can simply be installed using yum/rpm, but on others like OpenShift getting a pod to run with root access can be somewhat tricky. 

### OpenShift
When running an application on OpenShift the pod will not have root access. It is possible to configure such access but that means configuring the OpenShift environment. This section provides an alternative to that which allows debugging the application using a remote gdb session. This is done by starting a container in the same cluster with an image with the node runtime and debuginfo, and then connecting to the pod that is the target of the debugging.

The example used in this document is [nodejs-rest-http](https://github.com/bucharest-gold/nodejs-rest-http).

#### Start/attach to the running process
First step is to start the gdbserver on the pod that is the target of the debugging session:
```
$ oc rsh nodejs-rest-http-1-nw7hz
```
We want to attach the `gdbserver` to the node process (`30` in this case but can differ):
```console
sh-4.2$ ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
1000120+     1     0  0 03:58 ?        00:00:00 npm
1000120+    30     1  0 03:58 ?        00:00:00 node .
1000120+    41     0  0 03:59 ?        00:00:00 /bin/sh
1000120+    45    41  0 03:59 ?        00:00:00 ps -ef
$ gdbserver 172.17.0.6:7777 --attach 30
Attached; pid = 30
Listening on port 7777
```
The gdbserver is now listening for connections.

#### Start the debuginfo image
The next step is to start a container with the debuginfo image in the same cluster.

```console
$ oc run -i -t nodejs-debuginfo --image=bucharestgold/centos7-s2i-nodejs-debuginfo:10.x --restart=Never
```
Running the above command will drop you into the newly created container where 
the gdb session can be started. This is done using the following command: 
```console
bash-4.2$ gdb node
Reading symbols from /usr/bin/node...Reading symbols from /usr/lib/debug/usr/bin/node.debug...done.
done.
(gdb)
```
Then, start a remote debugging session to the target pod:
```console
(gdb) target remote 172.17.0.6:7777
```
Next breakpoints can be set and debugging can start. For this example we want to 
set a breakpoint in [ConnectionWrap::OnConnection](https://github.com/nodejs/node/blob/972d0beb591859a1a0df59a3d1818493a6132bf5/src/connection_wrap.cc#L34) which will be hit when accessing the nodejs-rest-http application:
```console
(gdb) break connection_wrap.cc:36
Breakpoint 1 at 0x979074: connection_wrap.cc:36. (2 locations)
```

Next, we need to trigger the breakpoint, which can be done by accessing the endpoint exposed by the application. To find that endpoint url, use the following command:
```console
$ oc get route
NAME               HOST/PORT                                          PATH      SERVICES           PORT      TERMINATION   WILDCARD
nodejs-rest-http   nodejs-rest-http-myproject.192.168.99.100.nip.io             nodejs-rest-http   8080                    None
```
Open `http://nodejs-rest-http-myproject.192.168.99.100.nip.io` in a web browser. This will "hang" as the breakpoint will have been hit and waiting for interaction. Switch back to the console with the debugger and you can inspect variables and step through the code:
```console
(gdb) print status
$2 = 0
(gdb) print handle
$3 = (uv_stream_t *) 0x2878268
```
To resume normal execution use `continue`:
```console
(gdb) continue
```


### Install debuginfo
This option can be used in cases where root access is available.

The following shows an example of installing debuginfo for `v10.11.0`:
```console
yum install -y https://github.com/bucharest-gold/node-rpm/releases/download/v10.11.0/rhoar-nodejs-debuginfo-10.11.0-1.el7.centos.x86_64.rpm
```
After installing the debuginfo package start gdb and attach to the node process:
```console
$ gdb --pid=23
```
Breakpoints can now be enabled in the same manner as was shown previously in this document.
