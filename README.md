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
- "bashdown" files with frontmatter-like headers
- bash scripts (or any other binary/executable script/application, if you change a setting in reXply config)

### Regular text files

No secrets on this. I just recommend you append .txt to the file names so your editors do not try to apply syntax highlighting based on file contents.

### Bashdown files

You can add bash commands within **$()** on your file. These will be executed by bash and replaced dynamically within the template.

Environment variables like $USER, $PWD, etc are also replaced - even when outside $().

### Bashdown files with frontmatter-like headers

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

#### Currently accepted variable types

1. text or entry (single line input)
   - `text:customer` (the default value will be `customer` as the var name)
   - `text:customer:` (adding a trailing `:` the default value will be empty)
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

#### A quick tip:

- you can type `\\n` while filling in frontmatter variables data - reXply will convert these to line breaks when pasting the data to your application.

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

- [ ] do further tests with OSX (help is welcome)
- [ ] provide a way to create new bashdown + frontmatter files using the script
- [ ] get rich

## More info regarding the dependencies

1. `dmenu` is the standard application used to output information and capture input due to it's more widespread presence - including availability on OSX via Homebrew, etc. If you want more fancy visuals, change both `$lighter` and `$suplite` variables to `0` so you can use `yad` instead for all functions that would use `dmenu` (leaving `$lighter` enabled and `$suplite` disabled, `yad` will be used only to process files with "bashdown frontmatter templates").
2. `xclip` may be substituted with `xsel` with quick edits to the script, but xclip is also widespread and demonstrated to be more reliable on my tests. The script is somewhat "ready" to use `pbcopy` instead on OSX - I just had no time to test in OSX yet, so it may need some polishing.
3. `xdotool` is used to handle the copy of processed data to clipboard and pasting the data to the destination app. You can disable automatic pasting, or use "echo" as paste command and pipe this script output to `pbpaste`, etc and you can skip the dependency on `xdotool`.

## Donate

Help me keep my stuff Open Source and free.

Think on how much time($) you're saving with this tool and buy me some coffee! :)

> USD

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R58RLRMM8YM6U)

> BRL

[![Doar](https://www.paypalobjects.com/pt_BR/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9JMBDY5QA8X5A)

