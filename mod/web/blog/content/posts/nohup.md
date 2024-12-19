---
title: "Spawning background processes"
date: "2024-11-17"
---

Working in a terminal,
I often pair my editor with a background process watching files.
Before reaching for terminal multiplexers,
see if you can get away with simple tty job control.
Spawn the background process,
still attached to the terminal instance:

```
program args &
```

Also redirect its output to a file,
for when the process writes to the tty from the background:

```
nohup program args &
```

Extra reading:

- <https://jvns.ca/blog/2024/07/03/reasons-to-use-job-control/>
