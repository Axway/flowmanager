# Flowmanager

Helm deployment

1. Helm install

```shell
helm install  flowmanager ./flowmanager space=<your_namespace> -f flowmanager.yaml
```

2. **Helm update**

```shell
helm upgrade --install flowmanager ./flowmanager space=<your_namespace> -f your_values_file.yaml
```

3. **Helm delete**

```shell
helm delete flowmanager space=<your_namespace>
```
