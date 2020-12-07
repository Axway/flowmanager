### Flowmanager

**Helm deployment**

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