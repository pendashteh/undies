# undies
A minimalistic framework for writing bash programs.


## Installation

Place `undies` script in your `$PATH`.

Now all you need to do to include `. undies` at the end of your bash script. Undies will automatically recognize functions names as `function__` and variables named as `__var`.

## Hello World

The following is a simple undies script, called `hello.sh`
```bash
#! /usr/env/bin bash

__who="World"

world__ () {
  echo Hello ${__who}!
}

. undies
```

```bash
$ ./hello.sh
Hello World!

$ ./hello.sh --who "Universe"
Hello Universe!
```
