# Bash Autocomplete for Undies

Undies includes built-in bash autocomplete functionality that makes working with your CLI tools even faster and more intuitive.

## Quick Start

To enable autocomplete for your undies script, simply run the `__install` task:

```bash
# If you have a symlink in your PATH
$ myapp __install

# Or run directly from the script location
$ ./myapp.sh __install

# Then reload your shell
$ source ~/.bashrc
```

Now you can use tab completion:

```bash
$ myapp <TAB>          # Shows all available tasks
$ myapp __<TAB>        # Shows all available parameters
```

## How It Works

The `__install` task automatically:

1. **Detects the command name** from how you invoked the script (`$0`)
2. **Generates a completion function** with your current tasks and parameters
3. **Installs it** to `~/.bash_completion.d/`
4. **Registers the completion** for the command name you used

### Examples

```bash
# Symlink in PATH
$ myapp __install
# Registers completion for: myapp

# Direct invocation with relative path
$ ./deploy.sh __install
# Registers completion for: deploy.sh

# Direct invocation with full path
$ /home/user/apps/build/build__ __install
# Registers completion for: build__

# Override with explicit name
$ ./build__ __install build
# Registers completion for: build
```

## Setup Bash Completion Loading

If this is your first time using bash completions, add this to your `~/.bashrc`:

```bash
# Load user completions
for f in ~/.bash_completion.d/*; do 
    [[ -f "$f" ]] && source "$f"
done
```

Then reload:

```bash
$ source ~/.bashrc
```

## What Gets Autocompleted

### Tasks
All your task functions (functions ending with `__`) will be available for completion:

```bash
$ myapp <TAB>
deploy  backup  migrate  help
```

### Parameters
All your parameters (variables starting with `__`) will be suggested when you type `__`:

```bash
$ myapp __<TAB>
__port  __host  __env  __verbose
```

### Complete Example

```bash
$ myapp __<TAB>
__port  __host  __env

$ myapp __port=<ENTER>
# Continue typing...

$ myapp __port=3000 <TAB>
deploy  backup  migrate  help

$ myapp __port=3000 deploy
```

## Multiple Scripts

Each script needs its own completion installed:

```bash
$ deploy __install
$ backup __install
$ build __install
$ source ~/.bashrc
```

Each completion is independent and includes only that script's tasks and parameters.

## Updating Completions

When you add new tasks or parameters to your script, regenerate the completion:

```bash
$ myapp __install
$ source ~/.bashrc
```

This overwrites the previous completion with the updated one.

## Implementation Details

The `__install` task is part of the undies framework and is automatically available in all undies scripts. Here's what it does:

1. Calls `__tasks` to get all available tasks
2. Calls `__params` to get all available parameters  
3. Generates a bash completion function
4. Saves it to `~/.bash_completion.d/<command_name>`
5. Registers the completion for the detected command name

The completion function handles:
- Task name completion (when not typing `__`)
- Parameter name completion (when typing `__*`)
- The `help` command

## No Filename Assumptions

Undies makes **zero assumptions** about your script filenames:

- ✅ Works with or without extensions: `myapp`, `myapp.sh`, `myapp__`, `myapp.undies`
- ✅ Works with any naming convention
- ✅ Works with symlinks anywhere in your PATH
- ✅ Auto-detects from how you invoke `__install__`

## Troubleshooting

### Completion not working after install

Make sure bash completions are loaded in your `~/.bashrc`:

```bash
$ grep "bash_completion.d" ~/.bashrc
```

If nothing shows up, add the loader code shown above.

### Wrong command name

If you installed completion with the wrong command name, just reinstall with the correct one:

```bash
$ ./myapp__ __install myapp
$ source ~/.bashrc
```

### Completion file location

All completions are stored in `~/.bash_completion.d/`:

```bash
$ ls ~/.bash_completion.d/
deploy  backup  build  myapp
```

You can manually delete any completion file if needed.

### Testing completions

To test if completion is working:

```bash
$ myapp <TAB><TAB>
# Should show all tasks

$ myapp __<TAB><TAB>
# Should show all parameters
```

If it's not working, make sure you've sourced your bashrc after installation.
