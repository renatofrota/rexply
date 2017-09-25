# reXply
reXply - A handy tool to copy/paste replies and scripts from a 'repository', with advanced 'headers' system, inline substitutions, bashdown, bash script processing - also used as a 'launcher' to other scripts/executables!

## Dependencies

- `dmenu` and/or `yad`
- `xclip`
- `xdotool`

More info regarding these dependencies at the end of this file.

## How to install

- install as more dependencies you can on your system (dmenu, yad, xclip, xdotool) for easier operation
- if you are unsure how to install, just proceed with next steps (the script will try to install them - if you're using Linux)
- clone this repo, symlink the binary in a folder in your $PATH

```
cd ~/ ; git clone https://github.com/renatofrota/rexply.git
ln -s ~/rexply/rexply.bash $(echo $PATH|cut -d: -f1)/rexply
echo "reXply installed to $(echo $PATH|cut -d: -f1)/rexply"
```

It works from command line (terminal) - just type in 'rexply' - but it is only **1% as useful as it could be** by running it this way. To feel the power:

1. add the custom command `rexply` to your Keyboard shortcuts/keybindings area;
2. bind a key to the custom command you've created
3. go to an editor, browser, or any other text area field
4. press the binded key and be amazed!

## More advanced operation

The default replies/scripts repository is `$HOME/rexply/rexply-data/repository`. Just create more folders/files there.

The files can be:

- text files
- front-matter powered templates
- "bashdown" files (enabling `$runeval`)
- bash scripts (executable scripts - prerably with `#!/bin/bash` hashbang)
- or any other binary/executable script/application (after enabling `$execute`)

### Text files

No secrets on this. I just recommend you append .txt to the file names so your editors do not try to apply syntax highlighting based on file contents.

### Front-matter powered templates

Create a section with some variables at the top of the file (surround the variables by `---` above and below) and use them within template text. Example:

```
---
field:customer:Customer
txt:code
num:minutes:10!0..20!5
---
Hello ${customer},

Thanks for getting in touch with us.

To resolve this problem I've added this code to [b]public_html/.htaccess[/b] file on your account:

[code]${code}[/code]

This change should reflect in aproximately ${minutes} minutes.

@
```

When inserting this template, reXply will ask you to provide the data to the 3 variables:

- your customer's name
- the _code_ you've used to resolve his problem
- how many minutes it will take to reflect on his end

After the variable name, you can add `:` and the default input for that variable.

If using `dmenu`, you will see an empty field with a 'selection' below (the default input). You can type any value or just hit enter to use the pre-selected option. One field at a time. Optionally, a preview of all the fields can be displayed underneath the selector (`$preview='1'`).

If using `yad`, a form will be displayed, with all fields visible and editable simultaneously. Each field is pre-filled with the default value data (or the variable name, if you have set no default value). Numeric fields will have +/- buttons - and may be limited to the range you have defined. In the example above `!0..20!5` means _"a value between 0 to 20, in steps of 5"_. The "steps" are only for the +/- buttons (or up/down arrows): any value within the allowed range can be _manually_ entered.

Oh, and the @ at the end is to confirm you want the 2 blank lines processed (any `@` at the very end of the template is removed during processing - if `$checkpt` is enabled, or `-k 1` is passed). Without it, the 2 lines would be discarded.

#### Variables syntax

The syntax for a front-matter variable of type `field` accepts the 3 following formats:

1. `field:customer` - the default value will be `customer`, i.e.: the variable name
2. `field:customer:` - defaults to a literal `${varname}`, i.e.: the 'placeholder' var stay as is
3. `field:customer:Customer` - defaults to 'Customer'

#### Data variables types

Currently, 3 types of data variables are supported

1. `field`, `var`,  `text` or `entry` - single line input field
2. `txt` or `textarea` - multiline (textarea) input field
3. `num` or `numeric` - a field that only allow numbers [ with a default value [ a defined range of accepted values [ and a default stepping ] ] ] (`num:varname[:default[!MIN..MAX[!STEP]]]`)
   - a default is specified as usual: `num:minutes:10`
   - an accepted range is specific by appending `!MIN..MAX` (e.g.: `num:minutes:10!0..20`)
   - the stepping comes after, also separated by `!` (e.g.: `num:minutes:10!0..20!5`)
   - note: the acceptance of these settings depends on the application you use to process front-matter vars (`$yadform` or `-Y` parameter)
     - **yad**
       - accepts all parameters
       - the visual +/- buttons and up/down keyboard arrows respect the range and stepping
       - you can still manually type a value out of the range and/or disrespecting the stepping
     - **dmenu**
       - takes the default value
       - discard all the rest

#### Front-matter overrides variables

4 special front-matter variables can be used to override reXply options.

They accept `1`/`0`, like the config vars, or aliases like `true`/`false`, `yes`/`no`, etc).

1. `yadform` or `editor` (overrides `$yadform`)
2. `preview`
3. `literal`
4. `runeval`

#### Specifics of each _form-filling_ utility

- dmenu:
  - It does not allow you paste data.
  - Enter submit data. To add line breaks, type `\\n`.
- yad:
  - It allows you paste data on it's fields. However, you cannot use `|` in provided data as it will break the field<->data association (any data after a `|` will be associated to the next field and all the next are also pushed 1 field down).
  - You may find it hard to tabulate textarea fields. Use Ctrl+tab.

#### Comments within front-matter header

```
---
field:var_name:default value#this is a comment (variable is processed)
#this line is also a comment. this method or above are valid and recommended
this line is not a comment but parsing will fail: 'this' is not a valid variable type
---
```

#### Front-matter tips:

1. you can type `\\n` while filling in front-matter variables data - reXply will convert these to line breaks when pasting the data to your application.
2. the preview lines (those displayed below `dmenu` when `$yadform='0'` (`-Y 0`), while processing a file with front-matter variables) are "filtered" as you type - and will eventually disappear: as soon as your data input do not match any of them. If it is a problem for you (you ends up selecting an existing item when trying to insert a data with shorter lenght to the next fields) you can resolve by one of the methods below (_"it's simple, I will disable preview in config"_, you may think at first - yes, it works, but there are smarter ways to "fix" it without taking it hard):
  - disable preview specifically for that template, by adding `preview:false` to it's front-matter;
  - use less-common words as variable names (or just combine words like `customer_name`);
  - change the order of variables in the front-matter (place variables that expects a _shorter **input** at the top_);
  - prepend all them with a _prefix__ (e.g.: `field:field_customer:Customer`), making the variable names still _readable_ but much less likely (near impossible) to match your input data;
  - make the variables' names all uppercase;

### Bashdown files

You can add bash subshells `$()` on your file. These will be executed (**with your homedir as their initial working directory**) and their output will replace the subshell dynamically in the template (just like as any command you run in your shell).

Environment variables like `${USER}`, `${PWD}`, etc are also replaced _even when outside `$()`_

Note: some consider eval dangerous (have you ever heard _eval is evil_?) so environment vars substitutions is made using just `envsubst` by default - if you want to go evil way, I mean.. eval way, enable eval by setting `$runeval='1'`, passing `-E 1` parameter, or add `runeval:true` to template).

### Bash scripts

They are **executed** when selected in the menu and you have execution permissions over the file (`chmod +x path/to/filename.bash`).

Be careful. Your homedir is the initial working directory when you start reXply using a keybinding. When running from command line, the working dir is kept.

Please note:

1. if the file is not executable, no matter the extension, it will be processed as a regular text/bashdown template.
2. the files are not executed direcly by default (`$execute='0'`), they are called through `bash`, like this: `bash <file>`.
3. If you enable `$execute` or pass `-X 1` the file will be executed **direcly**, making reXply act as a truly and independent "launcher" for your applications/scripts.

I recommend you add `#!/bin/bash` hashbang at the top of the file and use `.bash` or `.sh` extension so your text editors also know they are shell executable files - and they keep being properly executed if you enable `$execute`.

## More information

reXply will, by default:

- [x] hide directories and files preceded by a dot (e..g: `.filename`) - `$showall='0'`
- [x] disallow browsing to parent directories outside it's default repository - `$breakit='0'`
- [x] hide form list any file bigger than a pre-defined size limit (default: 3MB) - `$maxsize='3'`
- [x] prevent execution of arbitrary executables (call executables using `bash $filename`) - `$bashit='1'`

All these restrictions are due to security concerns and can be modified by either:

- modifying the rexply file directly (`$HOME/rexply/rexply.bash`); or
- modifying the additional config file (`$HOME/rexply/rexply.cfg`)

We will avoid updating the additional config file but _take your backups before updating_, please.

## To-do

- [ ] test if everything works in OSX (help wanted)
- [ ] improve textarea fields (the pipe char `|` currently breaks field<->data associations)
- [ ] provide a way to create new bashdown files with front-matter variables using the script itself
- [ ] buy more coffee (please donate below!)

## More info regarding the dependencies

- `dmenu` is the standard application used to output information and capture input due to it's more widespread presence - including availability on OSX via Homebrew, etc. If you want more fancy visual, with screen-centered dialogs, ability to fill in all front-matter variables of a template in a single - floating window - form, set options `$yadfile` (file selection) and `$yadform` (front-matter form) to `1` (or run `rexply -y 1 -Y 1`) so you can use `yad` instead.
- `xclip` may be substituted with `xsel` (see `$copycmd` option) or `pbcopy` and `pbpaste` - useful in OSX, I just had no time to test yet, so it may need some polishing.
- `xdotool` is used to handle the window focus (and apparently, it's not that easy to make it work on OSX due to `XTEST` not being active by default). You can get rid of this dependency by disabling `$focusit` option. A possible problem if you are using the script to paste data (with `xclip` or `xsel`) while another window is set as _'always-on-top'_: the data will sometimes end up being pasted to the window set as _'always-on-top'_ instead the desired window (depends on the application and other circumstances - not tested on OSX yet).

## OSX

`xdotool` is used to paste in Linux by default. In OSX, the default is **no automatic pasting** and using pbcopy/pbpaste instead (`$pasteit='0'` and `$copycmd='3'`). The processed data should be on your clipboard, just paste it manually after running reXply.

If you want to try automatic pasting, there are 2 ways to implement it:

1. set `$pastedefault='eval cat $1'` and `$pasteterminal='eval cat $1'` (or just pass `-P 'eval cat $1'` parameter) - **note the single quotes** - and pipe reXply to whichever program you want to use to handle the data in sequence. Just as an example, at least theoretically, piping the output to `pbcopy` (e.g.: `rexply -P 'eval cat $1' | pbcopy`) the data will be copied to clipboard (as reXply does by default) and you can paste it manually. I could not test (pbcopy not available in my Linux distro and `xclip`/`xsel` handles input buffer a bit differently). Feel free to try this and other ways to parse the output :)
2. there's another option: disable automatic pasting with `$pasteit='0'` (what is default for OSX) and also set it to keep the _tmpfile_ after processed (`$deltemp='0'` or `-d 0`), then use the processed data saved at _tmpfile_ (by default, `$HOME/rexply/rexply-data/.tmp/tmp`) by your own way.

## Donate

Help me keep my stuff Open Source and free.

Think on how much time($) you're saving with this tool and buy me some coffee! :)

> USD

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R58RLRMM8YM6U)

> BRL

[![Doar](https://www.paypalobjects.com/pt_BR/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9JMBDY5QA8X5A)
