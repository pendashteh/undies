# Undies

A minimalist bash application framework that makes building CLI tools delightfully simple.

## Philosophy

Undies embraces bash's strengths while hiding its weirdness. Write simple functions, declare parameters, and get a fully-featured CLI app with help text, parameter parsing, and task execution—all without learning bash quirks.

## Quick Start

Create a file `hello.sh`:

```bash
__message=${HELLO__message='Hello, World!'}

greet__help="@arg name @does greet someone"
greet__ () {
  echo ${1:-$__message}
}

. undies
```

Make it executable and run:

```bash
$ chmod +x hello.sh
$ ./hello.sh
# Shows help with available tasks and parameters

$ ./hello.sh greet
Hello, World!

$ ./hello.sh __message="Hey there!" greet
Hey there!

$ ./hello.sh greet "Alice"
Alice
```

## Core Concepts

### Tasks

Tasks are bash functions ending with double underscore `__`:

```bash
deploy__help="@does deploy the application"
deploy__ () {
  echo "Deploying..."
}
```

### Parameters

Parameters use a naming convention that enables defaults and environment overrides:

```bash
__port=${MYAPP__port='8080'}
__host=${MYAPP__host='localhost'}
```

- **`__port`** - the variable used in your code
- **`MYAPP__port`** - environment variable for override
- **`'8080'`** - default value

### Help Text

Document tasks with help variables:

```bash
task__help="@arg argument @does description of what this task does"
```

## Usage Patterns

### Basic Task Execution

```bash
$ ./app.sh task
$ ./app.sh __param=value task
$ ./app.sh __param1=value1 __param2=value2 task
```

### Getting Help

```bash
$ ./app.sh help              # Show all tasks
$ ./app.sh help taskname     # Show specific task details
$ ./app.sh                   # Shows help by default
```

### Multiple Script Execution

```bash
$ undies -- script1.sh -- script2.sh
$ undies -- __port=3000 app.sh start
```

## Lifecycle Hooks

Override these functions to add custom behavior:

```bash
__puton__help="@does runs before any task"
__puton__ () {
  echo "Starting task: $__task__"
}

__takeoff__help="@does runs after successful task completion"
__takeoff__ () {
  echo "Completed task: $__task__"
}

__fallback__help="@does runs when task fails or is not found"
__fallback__ () {
  echo "Task failed: $__task__"
}
```

### Default Task

Define a custom default when no task is specified:

```bash
__default__help="@does show status"
__default__ () {
  echo "Application status: running"
}
```

## Undies Functions for App Developers

Undies provides helper functions you can use in your tasks:

### `__exec`

Execute commands with built-in display and confirmation:

```bash
deploy__ () {
  __exec "git pull origin main"
  __exec "npm install"
  __exec "npm run build"
}
```

The user will see each command and can confirm before execution.

### `__exists`

Check if a task function exists:

```bash
if __exists backup__; then
  backup__
fi
```

### `__tasks`

Get a list of all available tasks:

```bash
list__help="@does list all available tasks"
list__ () {
  for task in $(__tasks); do
    echo "- $task"
  done
}
```

### `__params`

Get a list of all declared parameters:

```bash
show_config__help="@does show current configuration"
show_config__ () {
  echo "Current parameters:"
  __params
}
```

### `__app`

Get the application name:

```bash
version__help="@does show application info"
version__ () {
  echo "$(__app) version 1.0"
}
```

### `t` (template)

Simple string templating for output:

```bash
declare -A vars
vars[name]="Alice"
vars[age]="30"

t "Hello, @name! You are @age years old." vars
# Output: Hello, Alice! You are 30 years old.
```

## Undies Variables for App Developers

Undies exposes variables you can use in your tasks:

### `$__src__`

The full path to the current script file:

```bash
backup__help="@does backup this script"
backup__ () {
  cp $__src__ $__src__.backup
  echo "Backed up to $__src__.backup"
}
```

### `$__path__`

The directory containing the current script:

```bash
# Source additional libraries relative to your script
source $__path__/lib.sh
source $__path__/config.sh

# Access data files
cat $__path__/data/users.txt
```

This works even when the script is run from a different directory:

```bash
$ cd /tmp
$ /home/user/myapp/app.sh task
# $__path__ will be /home/user/myapp
```

### `$__task__`

The name of the currently executing task:

```bash
__puton__ () {
  echo "Running task: $__task__"
}
```

### `$__API__`

The Undies API version (currently 4):

```bash
if [[ $__API__ -lt 4 ]]; then
  echo "This script requires Undies API version 4 or higher"
  exit 1
fi
```

## Examples

### Simple Todo App

```bash
#!/usr/bin/env bash

__file=${TODO__file="$HOME/.todos"}

add__help="@arg task @does add a new todo"
add__ () {
  echo "- [ ] $*" >> $__file
  echo "Added: $*"
}

list__help="@does list all todos"
list__ () {
  cat $__file 2>/dev/null || echo "No todos yet!"
}

done__help="@arg number @does mark todo as complete"
done__ () {
  sed -i "${1}s/\[ \]/[x]/" $__file
  echo "Marked todo $1 as complete"
}

. undies
```

### Deployment Script

```bash
#!/usr/bin/env bash

__env=${DEPLOY__env='staging'}
__branch=${DEPLOY__branch='main'}

deploy__help="@does deploy application to specified environment"
deploy__ () {
  __exec "git fetch origin"
  __exec "git checkout $__branch"
  __exec "git pull origin $__branch"
  __exec "npm install"
  __exec "npm run build"
  __exec "rsync -av ./dist/ server-$__env:/var/www/"
  __exec "ssh server-$__env 'systemctl restart app'"
}

rollback__help="@does rollback to previous deployment"
rollback__ () {
  __exec "ssh server-$__env 'cd /var/www && git checkout HEAD~1'"
  __exec "ssh server-$__env 'systemctl restart app'"
}

. undies
```

### Multi-file Application

```bash
#!/usr/bin/env bash
# main.sh

# Source libraries relative to script location
source $__path__/lib/database.sh
source $__path__/lib/helpers.sh

__db_host=${APP__db_host='localhost'}

migrate__help="@does run database migrations"
migrate__ () {
  db_connect $__db_host
  db_migrate
}

. undies
```

## Installation

### Option 1: Direct Download

```bash
curl -o undies https://raw.githubusercontent.com/yourrepo/undies/main/undies
chmod +x undies
sudo mv undies /usr/local/bin/
```

### Option 2: Source in Scripts

Download `undies` and source it at the end of your script:

```bash
#!/usr/bin/env bash

# Your tasks here
task__ () {
  echo "Hello"
}

# Source undies
. /path/to/undies
```

### Option 3: Run Scripts Directly

```bash
undies -- /path/to/your-app.sh task
```

## Experimental Features

The following features are experimental and may change in future versions:

### Dry Run Mode

Use `__dryrun` parameter to preview commands without executing:

```bash
$ ./app.sh __dryrun=1 deploy
# Commands will be shown but not executed
```

### Verbose Output

Use `__verbose` parameter for detailed logging:

```bash
__verbose=${MYAPP__verbose='0'}

deploy__ () {
  [[ $__verbose -ge 1 ]] && echo "[INFO] Starting deployment"
  [[ $__verbose -ge 2 ]] && echo "[DEBUG] Checking prerequisites"
}
```

```bash
$ ./app.sh __verbose=2 deploy
```

### Namespaced Tasks

Organize related tasks with double underscores:

```bash
db__migrate__help="@does run database migrations"
db__migrate__ () {
  echo "Migrating database..."
}

db__seed__help="@does populate database with test data"
db__seed__ () {
  echo "Seeding database..."
}
```

```bash
$ ./app.sh db__migrate
$ ./app.sh db__seed
```

### Error Codes

Custom error codes for specific failure conditions:

```bash
_err_fn_na=101  # Function does not exist
```

## Ideas to Explore

Here are patterns you might want to implement in your undies applications:

### Environment File Loading

Load configuration from `.env` files:

```bash
__env=${MYAPP__env='development'}

# In your script initialization
[[ -f $__path__/.env ]] && source $__path__/.env
[[ -f $__path__/.env.$__env ]] && source $__path__/.env.$__env

start__help="@does start the application"
start__ () {
  echo "Starting in $__env environment"
}
```

Usage:
```bash
$ ./app.sh __env=production start
```

### Task Dependencies

Run prerequisite tasks before main tasks:

```bash
build__help="@does compile the application"
build__ () {
  echo "Building..."
}

deploy__help="@does deploy (builds first)"
deploy__ () {
  build__  # Run build task first
  echo "Deploying..."
}
```

### Parameter Validation

Validate parameters before running tasks:

```bash
__port=${MYAPP__port='8080'}

__puton__ () {
  if [[ $__port -lt 1 || $__port -gt 65535 ]]; then
    echo "Error: port must be between 1 and 65535"
    return 1
  fi
}
```

### Configuration Management

Store and load configuration:

```bash
config__help="@does show current configuration"
config__ () {
  echo "Configuration from: $__path__/config"
  cat $__path__/config 2>/dev/null || echo "No config file found"
}

save_config__help="@does save current parameters to config file"
save_config__ () {
  __params > $__path__/config
  echo "Configuration saved"
}
```

## Why Undies?

- **Simple**: Write bash functions, get a CLI tool
- **Consistent**: Standard conventions for parameters and tasks
- **Documented**: Auto-generated help from your code
- **Portable**: Pure bash, works everywhere
- **Minimal**: ~200 lines of bash, zero dependencies

## License

GPL v3

## Contributing

Contributions welcome! Please open an issue or pull request.

## Credits

The entire source code is human-made.
This readme file is made by Claude Sonnet 4.5. (with minor tweeks)

