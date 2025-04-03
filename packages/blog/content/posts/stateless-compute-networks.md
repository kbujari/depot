---
title: "On stateless compute networks"
date: "2024-11-10"
draft: true
---

On the topic of distributed systems and clustering,
I am quite invested in the idea of compute nodes that rely entirely on the network for configuration.
Arbitrary nodes can join a pre-existing cluster,
offering their CPU time and memory for computation without relying on any pre-existing configuration on the node itself.
In other words, any computer could pick up work,
only needing power and a network connection to the cluster.

Perhaps this eventually leads into a "self-healing" cluster where only one node is manually bootstrapped,
which then serves a _configuration endpoint_ for other stateless nodes to reach out to for their instructions,
which they will then also serve once they are themselves ready.

Early revisions of these notes mention Kubernetes,
but I am also trying to achieve similar results with NixOS on a custom project.
In any case, these are my ever-updating notes towards a general implementation of a stateless distributed systems architecture.

## Self healing cluster

Assuming control of an external DHCP server,
a self healing Kubernetes cluster would be feasible,
with the PXE boot artifacts supplied by the cluster itself.
That is, as long as one node is running the pod hosting the artifacts on a given endpoint,
other nodes can boot those artifacts and join the cluster,
thereby being able to host the artifacts as well.

## Configuration endpoint

The nodes shouldn't require a disk installed to be able to join the network.
Rather, the lofty goal of zero-configuration compute nodes passes the job of node initialization to the supporting network.
This is accomplished with PXE boot instructions supplied over DHCP.

I delegate the following tasks to a single node in the subnet:

- Gateway: Optional outbound connections if required
- DHCP server: Cluster IPAM
- TFTP and HTTP server: Serves iPXE firmware and kernel/initrd artifacts
