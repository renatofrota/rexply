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

The default replies/scripts repository is **$HOME/rexply/rexply-data/repository**. Just create more folders/files there.

The files can be:

- regular text files
- "bashdown" files
- "bashdown" files with front-matter headers
- bash scripts (or any other binary/executable script/application, if you change a setting in reXply config)

### Regular text files

No secrets on this. I just recommend you append .txt to the file names so your editors do not try to apply syntax highlighting based on file contents.

### Bashdown files

You can add bash commands within **$()** on your file. These will be executed by bash and replaced dynamically within the template.

Environment variables like $USER, $PWD, etc are also replaced - even when outside $().

### Bashdown files with front-matter headers

Create a section at the top of the file, with one or more variables. Each variable can have.

- the variable type
- the variable name
- the variable default data (optional)

Then, re-use the variables within the file:

```
---
text:customer
txt:code
num:minutes:10!0..20
---
Hello ${customer},

Thanks for getting in touch with us.

To resolve this problem I've added this code to .htaccess:

[code]${code}[/code]

This change should reflect in aproximately ${minutes} minutes.


```

When inserting this template, reXply will ask you to provide the data to the 3 variables:

- the customer username (pre-filled as "Customer")
- the code _you've used to resolve the problem_ (as stated in this template)
- in how many minutes before the changes should reflect (a field pre-filled with "10" and freely editable - if using dmenu - or with nice +/- buttons and limited to 0-20 - if using yad)

#### Variable types and syntax

The currently accepted front-matter variable types and syntax are the following (this list will grow):

1. text or entry (single line input)
   - `text:customer` (the default value will be `customer`, i.e.: the variable name)
   - `text:customer:` (defaults to a literal `${varname}`, i.e.: the placeholder vars stays on template)
   - `text:customer:-`
   - `text:customer:Customer` 
   - `text:customer:John`
2. txt or textarea (multiline input)
   - `txt:instructions`
   - `txt:instructions:`
   - `txt:instructions:Access URL X and click button Y`
3. num (default numeric value [with a defined range of accepted values])
   - `num:minutes`
   - `num:minutes:`
   - `num:minutes:10`
   - `num:minutes:10!0..20`
4. preview (used just to control if previewing of all front-matter variables in dmenu is enabled)
   - `preview:true` (or aliases: on, yes, enable(d), 1)
   - `preview:false` (or aliases: off, no, disable(d), 0)

#### Comments within front-matter header

```
---
text:var_name:default value#this is comment (variable is processed)
#numthis line is also a comment
this line is not exactly a comment but will be ignored: 'this' is not a valid variable type
---
```

#### Front-matter tips:

- you can type `\\n` while filling in front-matter variables data - reXply will convert these to line breaks when pasting the data to your application.
- the preview lines (those displayed below dmenu when `$preview='1'` is set, while processing a file with front-matter variables) are "filtered" as you type and will eventually disappear: once the input text do not match any of them! If it is a problem (you often ends up selecting an existing item) you can:
  1. disable preview in config (obviously);
  2. use less-common words as variable names;
  3. prepend them with a _prefix__ (e.g.: `field_customer`) making the variable names still _readable_ but much less likely (near impossible) to match your input data;
  4. add a field `preview:false` to disable field preview for a particular file. The same way you can add a field 'preview:true' to enable preview for a particular file if/when globally disabled in reXply config.

### Bash scripts

They are **executed** when selected in the menu (be careful!)

For these, I recommend you:

- use .sh or .bash extension
- add **#!/bin/bash** hashbang at the top
- make them executable with **chmod +x path/to/filename.bash**

## More information

reXply will, by default:

- [x] disallow browsing to parent directories outside it's default repository
- [x] hide directories and files preceded by a dot (.filename)
- [x] hide form list any file bigger than a pre-defined size limit (default: 3MB)
- [x] prevent execution of any arbitrary executably, by executing them as "bash $filename"

All these restrictions are due to security concerns and can be modified by either:

- modifying the rexply file directly (**$HOME/rexply/rexply.bash**); or
- modifying the additional config file (**$HOME/rexply/rexply.cfg**)

We will avoid updating the additional config file but take your own backups, please.

## To-do

- [ ] test if everything works in OSX (help wanted)
- [ ] re-factor some giant functions to smaller, dedicated functions
- [ ] improve textarea fields (the char `|` currently breaks field<->text association)
- [ ] provide a way to create new bashdown files with front-matter variables using the script itself
- [ ] buy more coffee (please donate below!)

## More info regarding the dependencies

- `dmenu` is the standard application used to output information and capture input due to it's more widespread presence - including availability on OSX via Homebrew, etc. If you want more fancy visuals, change both `$lighter` and `$suplite` variables to `0` so you can use `yad` instead for all functions that would use `dmenu` (leaving `$lighter` enabled and `$suplite` disabled, `yad` will be used only when processing files containing a "bashdown front-matter template").
- `xclip` may be substituted with `xsel` (see `$copycmd` option) or `pbcopy` and `pbpaste`, useful in OSX - I just had no time to test yet, so it may need some polishing.
- `xdotool` is used to handle the window focus (and apparently, it's not that easy to make it work on OSX due to `XTEST` not being active by default). You can get rid of this dependency by disabling `$focusit` option. Possible problems:
  - \(requires more testing) if you are using the script to paste data (with `xclip` or `xsel`) while another window is set as _'always-on-top'_: the data will most likely end up being pasted to the window set as _'always-on-top'_ instead the desired window.
  - you still need to paste (xdotool is used by default). To this, you have 2 alternatives:
    1. use `$pastedefault='eval cat $tmpfile'` (**with single quotes**) as paste command and pipe this script output to `pbcopy` (e.g.: `rexply | pbcopy`) - the data will be copied to clipboard, now just paste it manually; or
    2. disable automatic pasting (`$pasteit='0'`) and set it to keep the _tmpfile_ after processed (`$killtmp='0'`), then use the processed data saved as _tmpfile_ (by default, `$HOME/rexply/rexply-data/.tmp/tmp`) by your own ways.

## Donate

Help me keep my stuff Open Source and free.

Think on how much time($) you're saving with this tool and buy me some coffee! :)

> USD

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R58RLRMM8YM6U)

> BRL

[![Doar](https://www.paypalobjects.com/pt_BR/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9JMBDY5QA8X5A)

