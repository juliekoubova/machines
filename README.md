# Machine Provisioning Scripts

To bootstrap a new machine, run
```shell
# wget https://raw.github.com/juliekoubova/machines/main/bootstrap -q -O - | sh
```

To unlock the secrets, install `git-crypt` and run
```shell
git-crypt unlock /path/to/the/keyfile
```
