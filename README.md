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

- it works from command line (terminal) - just type in 'rexply' - but it is only **1% as useful as it could be** by running it this way.
- to feel the power:
  1. add the custom command `rexply` to your Keyboard shortcuts/keybindings area;
  2. bind a key to the custom command you've created
  3. go to an editor, browser, or any other text area field
  4. press the binded key and be amazed!

## More advanced operation

The default replies/scripts repository is `$HOME/rexply/rexply-data/repository`. Just create more folders/files there.

The files can be:

- regular text files
- "bashdown" files
- "bashdown" files with front-matter headers
- bash scripts (or any other binary/executable script/application, if you change a setting in reXply config)

### Regular text files

No secrets on this. I just recommend you append .txt to the file names so your editors do not try to apply syntax highlighting based on file contents.

### Bashdown files

You can add bash commands within `$()` on your file. These will be executed by bash (**with your homedir as initial working directory**) and their output will replace the command dynamically in the template.

Environment variables like `${USER}`, `${PWD}`, etc are also replaced _even when outside `$()`_.

### Bashdown files with front-matter headers

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

#### Variable types and syntax

The currently accepted front-matter variable types and syntax are the following (this list will grow):

1. `field`, `var`, `text` or `entry`: regular text input field
   - `field:customer` (the default value will be `customer`, i.e.: the variable name)
   - `field:customer:` (defaults to a literal `${varname}`, i.e.: the placeholder vars stays on template)
   - `field:customer:-`
   - `field:customer:Customer` 
   - `field:customer:John`
2. `txt` or `textarea`: multiline (textarea) input field
   - `txt:instructions`
   - `txt:instructions:`
   - `txt:instructions:Access URL X and click button Y`
3. `num` or `numeric`: field that _defaults_ to a numeric value [with a defined range of accepted values]
   - `num:minutes`
   - `num:minutes:`
   - `num:minutes:10`
   - `num:minutes:10!0..20`
4. `preview`: override `$preview` setting for a particular template file
   - `preview:true` (or aliases: on, yes, enable(d), 1)
   - `preview:false` (or aliases: off, no, disable(d), 0)
5. `editor`: override `$yadform` setting for a particular template file
   - `editor:true` (or aliases: yad, full, gui, visual, on, enable(d), 1)
   - `editor:false` (or aliases: dmenu, light, cli, text, off, disable(d), 0)

#### Specifics of each _form-filling_ utility

- dmenu:
  1. It does not allow you paste data.
  2. Enter submit data. To add line breaks, type `\\n`.
- yad:
  1. It allows you paste data on it's fields. However, you cannot use `|` in provided data (it will break the field<->data association: any data after a `|` will be associated to the next field (and all the next are also pushed 1 field down).
  2. You may find it hard to tabulate textarea fields. Use Ctrl+tab.

#### Comments within front-matter header

```
---
field:var_name:default value#this is comment (variable is processed)
#numthis line is also a comment
this line is not exactly a comment but will be ignored: 'this' is not a valid variable type
---
```

#### Front-matter tips:

- you can type `\\n` while filling in front-matter variables data - reXply will convert these to line breaks when pasting the data to your application.
- the preview lines (those displayed below `dmenu` when both `$yadform='0'` (`-Y 0`), while processing a file with front-matter variables) are "filtered" as you type - and will eventually disappear: as soon as your data input do not match any of them. If it is a problem for you (you ends up selecting an existing item when trying to insert a data with shorter lenght to the next fields) you can resolve by one of the methods below (_"it's simple, I will disable preview in config"_, you may think at first - yes, it works, but there are smarter ways to "fix" it without taking it hard):
  1. disable preview specifically for that template, by adding `preview:false` to it's front-matter;
  2. use less-common words as variable names (or just combine words like `customer_name`);
  3. change the order of variables in the front-matter (place variables that expects a _shorter **input** at the top_);
  4. prepend all them with a _prefix__ (e.g.: `field:field_customer:Customer`), making the variable names still _readable_ but much less likely (near impossible) to match your input data;
  5. make the variable name all uppercase;

### Bash scripts

They are **executed** (from your homedir as initial working directory) when selected in the menu (**be careful!**)

For these, I recommend you:

- add `#!/bin/bash` hashbang at the top
- use .bash or .sh extension (so your text editors also know they are shell executable files)
- make them executable with `chmod +x path/to/filename.bash` (it's actually mandatory, or they will be parsed as a regular text template)

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
- `xdotool` is used to handle the window focus (and apparently, it's not that easy to make it work on OSX due to `XTEST` not being active by default). You can get rid of this dependency by disabling `$focusit` option. Possible problems:
  - \(requires more testing) if you are using the script to paste data (with `xclip` or `xsel`) while another window is set as _'always-on-top'_: the data will most likely end up being pasted to the window set as _'always-on-top'_ instead the desired window.
  - you still need to paste (xdotool is used by default). To this, you have 2 alternatives:
    1. use `$pastedefault='eval cat $1'` and `$pasteterminal='eval cat $1'` (**note the single quotes**) as paste command and pipe reXply to whichever program you want to use to handle this. Theoretically, piping the output to `pbcopy` (e.g.: `rexply | pbcopy`) the data will be copied to clipboard and you can just paste it manually in sequence. I could not test in Linux (pbcopy not available and `xclip`/`xsel` handle input buffer a bit differently), so in case it does not work, you can test the next options;
    2. set `$pasteit='0'` (or at least `$restore='0'`) and `$copycmd='3'` (or run reXply like this: `rexply -p 0 -c 3` / `rexply -r 0 -c 3`) and reXply will use `pbcopy` on it's own;
    3. there's still a third method: disable automatic pasting with `$pasteit='0'` and also set it to keep the _tmpfile_ after processed (`$killtmp='0'`), then use the processed data saved as _tmpfile_ (by default, `$HOME/rexply/rexply-data/.tmp/tmp`) by your own ways.

## Donate

Help me keep my stuff Open Source and free.

Think on how much time($) you're saving with this tool and buy me some coffee! :)

> USD

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R58RLRMM8YM6U)

> BRL

[![Doar](https://www.paypalobjects.com/pt_BR/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9JMBDY5QA8X5A)

