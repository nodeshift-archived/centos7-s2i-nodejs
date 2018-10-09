### GDB Debugging
This document describes the options available for debugging node using the GNU debugger.

We don't provide the debuginfo package, which contains the symbols required for debugging, as this would make our runtime image about 480MB larger. On systems where root access is allowed then the debuinfo package can simply be installed using yum/rpm, but on others like OpenShift getting a pod to run with root access can be somewhat tricky. 

### OpenShift
When running an application on OpenShift the pod will not have root access. It is possible to configure such access but that means configuring the OpenShift environment. This section provides an alternative to that which allows debugging the application using a remote gdb session. This is done by starting a container in the same cluster with an image with the node runtime and debuginfo, and then connecting to the pod that is the target of the debugging.

#### Start/attach to the running process
First step is to start the gdbserver on the pod that is the target of the debugging session:
```
$ oc rsh nodejs-rest-http-1-nw7hz
$ gdbserver 172.17.0.6:7777 --attach 23
Attached; pid = 23
Listening on port 7777
```
In the above case we are creating a new process, but this could also just be the process id of a process running on the pod.

#### Start the debuginfo image
The next step is to start a container with the debuginfo image in the same cluster.

```console
$ oc run -i -t nodejs-debuginfo --image=bucharestgold/centos7-s2i-nodejs2-debuginfo:10.x --restart=Never
```
Then start gdb specifying the executable which is `node` in our case: 
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
Next breakpoints can be set and debugging can start:
```console
(gdb) break main
Breakpoint 1 at 0x95df50: file ../src/node_main.cc, line 94.
(gdb) continue
Continuing.

Breakpoint 1, main (argc=3, argv=0x7fffffffe418) at ../src/node_main.cc:94
94      int main(int argc, char* argv[]) {
```


### Install debuginfo
This option can be used in cases where root access is available.

The following shows an example of installing debuginfo for `v10.11.0`:
```console
yum install -y https://github.com/bucharest-gold/node-rpm/releases/download/v10.11.0/rhoar-nodejs-debuginfo-10.11.0-1.el7.centos.x86_64.rpm
```
