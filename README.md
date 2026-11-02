# Kubernetes 1.37 Review

This repository contains the example manifests and local lab setup that accompany the YouTube Kubernetes 1.37 review video (https://youtu.be/-8TedKnGUmg). The examples focus on selected 1.37 changes and experiments; they are not a complete list of release features.

## Lab setup

The cluster uses [kind](https://kind.sigs.k8s.io/) and Docker. Install Docker, kind, and `kubectl` first. `kind/start.sh` uses `sudo` for Docker and kind operations; the image build requires Docker access for your user.

From the repository root, build the custom worker node image, then create the cluster:

```bash
cd custom-image
./build.sh
cd ../kind
./start.sh
```

The custom image builds containerd from the configured mount-options branch and is used by the worker node. Check that the cluster is ready before applying examples:

```bash
kubectl get nodes
kubectl get pods -A
```

The `kind/config.yaml` enables feature gates used by the manifests, including `VolumeBindMountOptions`, `EmptyDirVolumeMode`, `StatefulSetRecreateStrategy`, and `AtomicWriteVolumeUserFields`.

> **Caution:** `kind/start.sh` deletes and recreates the `k8s-1.37` cluster, removes the contents of this repository's `checkpoints/` directory, and replaces `~/.kube/config`. Save anything you need and back up your kubeconfig before running it.

## Examples

Apply the examples from this repository's directory with `kubectl apply -f <path>`.

| Directory | What it demonstrates |
| --- | --- |
| [`configmap-user/`](configmap-user/) | A Secret volume with per-file `user` and fallback `defaultUser` settings, alongside a ConfigMap-provided startup script. The manifest includes pods with and without those fields for comparison. |
| [`pod-hostname/`](pod-hostname/) | Compares the default pod hostname, `setHostnameAsFQDN`, and `hostnameOverride`. |
| [`pod-mount/`](pod-mount/) | Compares an `emptyDir` mount with one using `noexec` and `nosuid` bind-mount options, including a variant scheduled to the control-plane node. |
| [`statefulset/`](statefulset/) | Provides broken and fixed image examples, plus manifests using the StatefulSet `Recreate` update strategy. Apply one manifest at a time; they all define a StatefulSet named `nginx`. |
| [`custom-image/`](custom-image/) | Builds the custom kind worker image needed to test the mount-options example. |
| [`kind/`](kind/) | Contains the kind cluster configuration, registry host settings, and cluster startup script. |

For example, to run the hostname comparison:

```bash
kubectl apply -f pod-hostname/pod.yaml
kubectl get pods
kubectl exec hostname-standard -- hostname
kubectl exec hostname-fqdn -- hostname
kubectl exec hostname-override -- hostname
```

To remove that example:

```bash
kubectl delete -f pod-hostname/pod.yaml
```

Use the same apply/delete pattern for the other manifests. StatefulSet manifests share a resource name, so delete the current StatefulSet before switching variants if you want a clean comparison.

## Notes

- These examples are intended for a disposable local lab, not production clusters.
- The `pod-mount` example depends on the custom containerd build and the feature gate in `kind/config.yaml`.
- The control-plane node uses the stock `kindest/node:v1.37.0` image; the worker uses `kindest/node:v1.37.0-mount-options`.
- The custom image build fetches its containerd source branch at build time, so the resulting image may change as that branch changes.
