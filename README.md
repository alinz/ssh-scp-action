# SSH and SCP in GITHUB's Action

Execute commands and upload files to remove server in pure bash script

## USAGE

```yml
- name: Test
  uses: alinz/temp_actions/test@master
  env:
    HELLO: cool
    MESSAGE: hello world
  with:
    key: ${{ secrets.SSH_KEY }}
    host: example.com
    port: 22
    user: john

    # runs this on remove server
    ssh_before: |
      rm -rf sample1.dat sample2.dat
      echo $HELLO
      echo $MESSAGE
      ls -lath

    # then uploads these 2 files
    scp: |
      sample1.txt john@example.com:~/sample1.dat
      sample2.txt john@example.com:~/sample2.dat

    # then run these commands
    ssh_after: |
      echo $HELLO
      echo $MESSAGE
      ls -lath
```
