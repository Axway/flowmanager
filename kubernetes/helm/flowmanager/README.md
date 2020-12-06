### Flowmanager

1. **Please choose between 1 or 3 nodes installation**

    - flowmanager-1node
        - Changing the default values file in [flowmanager-1node.yaml](flowmanager-1node.yaml)
    - flowmanager-3nodes
        - Changing the default values file in [flowmanager-3nodes.yaml](flowmanager-3nodes.yaml)

2. **Helm deployment**

```console
$ helm install  flowmanager ./flowmanager space=<your_namespace> -f flowmanager.yaml
```

3. **Helm update**

```console
$ helm upgrade --install flowmanager ./flowmanager space=<your_namespace> -f your_values_file.yaml
```

4. **Helm delete**

```console
$ helm delete flowmanager space=<your_namespace> 
```