# reXply
reXply is a handy tool to copy/paste replies and scripts with an advanced front-matter system for variables substitutions and dynamic per-template settings, bash script processing/evaluation, and much more, that can also be used as a launcher to other scripts/executables!

## Current version

v0.1.8 - [View changelog](https://github.com/renatofrota/rexply/blob/master/rexply.bash#L850)

More info regarding these dependencies at the end of this file.

## Installation

First, clone this GitHub repo:

```cd ~ && git clone https://github.com/renatofrota/rexply.git```

Then, symlink the binary from a folder in your $PATH. e.g.:

```cd ~/bin && ln -s ~/rexply/rexply.bash rexply```

(assuming `$HOME/bin` is in your `$PATH`)

To install dependencies, create and initialize .rexply config dir:

```rexply -I```

If you use `Ctrl+V` to paste data to terminal (instead default `Ctrl+Shift+V`) like me:

```echo "pasteterminal='xdotool key ctrl+v'" >> ~/.rexply/rexply.cfg```

## Dependencies

All these may be istalled automatically just by running `rexply -I`:

- `yad` and/or `dmenu`
- `xclip` and/or `xsel` and/or `pbcopy`+`pbpaste`
- `xdotool` (optional - strongly recommended)
- `wmctrl` (optional)

## Upgrading

1. If you are using reXply below 0.1.8 and replies repository location is within reXply's directory, copy replies repository out of reXply's directory: `mkdir -p ~/.rexply ; cp -Rv ~/rexply/replies ~/.rexply/`
1. clone new version `cd ~ && rm -rf rexply && git clone https://github.com/renatofrota/rexply.git`

## Operation

It works from command line (terminal) - just type `rexply`. However it becomes much more great and useful after you:

1. go to control panel > keyboard > shortcuts
1. add the command `rexply` to custom shortcuts
1. bind a key to the custom command you've created (e.g.: ctrl+space or ';')
1. go to an editor, browser, or any other text area field and...
1. press the shortcut!

## Make it dance in your rhythm

The default replies/scripts repository is `$HOME/rexply/replies` (or `$HOME/.rexply/replies` if you followed all install steps above).

You can create more dirs and files inside the repository.

The files may be:

- regular text files
- text with dynamic questions
- 'front-matter powered' templates
- evaluated (processed with `eval`)
- bash scripts (a hashbang at the top of the file is recommended, e.g.: `#!/bin/bash`)
- or any other binary/executable script/application (may be disallowed passing `-X 0` or setting `$execute='0'`)

### Text files

No secrets on this. You may want (or not) to append .txt to the file names so your editors do not try to apply syntax highlighting based on file contents.

### Dynamic questions

You can add questions that will be dynamically replaced during text processing.

```
Hello, {{?Friend's name?}}! How are you going today?
```

When pasting this template, you will be asked "Friend's name?" (the last `?` is not part of dynamic questions syntax, it's part of the question itself).

### Front-matter powered templates

Create a section with some variables at the top of the file (surround the variables by `---` above and below) and use them within template text in format `${varname}`. Example:

```
---
var:customer!Customer name:
cbo:end!Reason of problem:our end!your end
txt:code!Code used to fix:if ($condition == "met") {\n\tdo this;\n}
num:minutes!Minutes to take effect:10!0..20!5
---
Hello ${customer},

Thanks for getting in touch with us.

This was caused by a problem on ${end}.

I've now resolved it using this code:

[code]${code}[/code]

This change should reflect in aproximately ${minutes} minutes.

@
```

When inserting this template, reXply will ask you to provide the data before processing the template:

1. your customer's name (empty field allowing any input);
1. the source of the problem (combo with options "our end"/"your end" - allowing a custom input);
1. the _code_ you've used to resolve the problem;
1. the time it will take to make effect.

After the variable name, you can add `:` and the default input for that variable. When no default is provided, variable name will be the default. To make default empty just add `:` and nothing after it (as the Customer's name in example above). You can enter line breaks and tabs to multiline fields (textarea) using `\n` and `\t` as in the example above, which will produce the default value:

```
if ($condition == "met") {
  do this;
}
```

If using `dmenu`, you will see an empty field with a 'selection' below (the default input). You can type any value or just hit enter to use the pre-selected option. One field at a time. Optionally, a preview of all the fields can be displayed underneath the selector (`$preview='1'`).

If using `yad`, a form will be displayed, with all fields visible and editable simultaneously. Each field is pre-filled with the default value data (or the variable name, if you have set no default value). Numeric fields will have +/- buttons - and may be limited to the range you have defined. In the example above `!0..20!5` means _"a value between 0 to 20, in steps of 5"_. The "steps" are only for the +/- buttons (or up/down arrows): any value within the allowed range can be _manually_ entered.

The `@` at the end is to confirm you want the 2 blank lines processed (any `@` at the very end of the template is removed during processing by default). Without it, the 2 last lines would be discarded.

#### Variables syntax

The syntax for a front-matter variable is `vartype:varname[!var label][:[default value]]`, where:

- `vartype` - variable type (see types below) - _mandatory_
- `varname` - variable name (used to perform the substitutions in template file) - _mandatory_
- `var label` - variable label displayed in Dmenu/Yad forms (defaults to `varname`)
- `the colon sign` - indicate a default value follows
- `default value` - default value (may be empty)

#### Data variables types

Currently, 5 types of data variables are supported

1. `entry`, `field`, `var` or `text` - single line
1. `txt` or `textarea` - multiline
1. `num` or `numeric` - only numbers (`num:varname[:default value[!MIN..MAX[!STEP]]]`)
1. `select` or `selectbox` - list of options (`select:varname[:option 1[!option 2[!option 3[!...]]]]`)
1. `combo` or `combobox` - like select field but allows custom values to be entered at runtime

`num` (or `numeric`) field type allow additional configuration at `default value` position

##### Numeric field type

It accepts a default value [ ! a defined range of accepted values [ ! and a default stepping ] ] ] 

- a default is specified as usual: `num:minutes:10`
- the accepted range is specified by appending `!MIN..MAX` (e.g.: `num:minutes:10!0..20`)
- the stepping comes after, also separated by `!` (e.g.: `num:minutes:10!0..20!5`)

The acceptance of these settings depends on the application you use to process front-matter vars (`$yadform` or `-Y` parameter)

- **yad**
  - accepts all parameters
  - the visual +/- buttons and up/down keyboard arrows respect the range and stepping
  - a value disrespecting the stepping may be entered manually (min/max are respected)
- **dmenu**
  - takes a the default value
  - disregard the rest (range and stepping)

#### Keeping variables untouched

You may want to display a `${variable}` in it's literal form (when it's part of the final command you want to run/paste after template is processed). There are 2 ways to do this:

1. add an entry variable and set the default value to the variable string: `entry:variable:${variable}`
   - it will be displayed during front-matter processing - and you can override it (as any `entry` var)
1. use the special front-matter command `keep`: `keep:variable`
   - it won't be displayed during front-matter processing at all

Note: variables in format `$variable` (without `{}`) are parsed from your environment variables.

#### Front-matter overrides variables

Some special front-matter variables can be used to override reXply options. Note: they must come before regular variables.

They accept `0`/`1`, like the config vars themselves, aliases like `true`/`false`, `yes`/`no`, and some others (check rexply.bash code if you're curious).

- `preview`
- `runeval`
- `bashcmd`
- `yadicon`
- `yadform` (or `editor`)

#### Specifics of each _form-filling_ utility

- yad:
  - Regular shortcuts (enter submit, tab change field)
  - On multiline textareas, ctrl+tab to change field
  - Note: you cannot enter `|` as it will break the field<->data association
- dmenu:
  - Enter submit selection or input
  - Shift+enter to submit input
  - Ctrl+y to paste primary X selection ("mouse highlight")
  - Ctrl+Y to paste clipboard

#### Comments within front-matter header

```
---
field:var_name:default value#this is a comment (variable is processed)
#this line is also a comment. this method or above are valid and recommended
this line raises a warning for parsing failure ('this' is not a variable type)
---
```

#### Front-matter tips:

1. you can type `\\n` while filling in front-matter variables data - reXply will convert these to line breaks when pasting the data to your application.
1. the preview lines (those displayed below `dmenu` when `$yadform='0'` (`-Y 0`), while processing a file with front-matter variables) are "filtered" as you type - and will eventually disappear: as soon as your data input do not match any of them. If it is a problem for you (you ends up selecting an existing item when trying to insert a data with shorter lenght to the next fields) you can resolve by one of the methods below (_"it's simple, I will disable preview in config"_, you may think at first - yes, it works, but there are *several* smarter ways to "fix" it without taking it hard):
   - use **shift+return** to submit to send your current input instead selected item
   - disable preview specifically for that template, by adding `preview:false` to it's front-matter;
   - change the order of variables in the front-matter (place variables that expects a _shorter **input** at the top_);

### Template evaluation (passing them through eval)

You can add bash subshells `$()` on your file. These will be executed (**with your homedir as their initial working directory** when reXply is called using a keyboard shortcut or your working directory when calling from terminal) and their output will replace the subshell dynamically in the template (just like as any command you run in a terminal window).

Environment variables like `${USER}`, `${PWD}`, etc are also replaced _even when outside `$()`_.

Note: some consider eval dangerous (have you ever heard _eval is evil_?) so environment vars and front-matter vars substitutions are made using just `envsubst` by default - if you want to go evil way, I mean.. eval way, enable eval by setting `$runeval='1'`, passing `-E 1` parameter, or add `runeval:true` to template front-matter).

### Bash scripts

They are **executed** when selected in the menu and you have execution permissions over the file (`chmod +x path/to/filename.bash`).

Be careful. Your homedir is the initial working directory when you start reXply using a keybinding. When running from command line, the working dir is kept.

Please note:

1. if the file is not executable, no matter it's extension, it will be processed as a regular text template.
1. when `$execute='0'` (or `-X 0`) the files are not executed directly but through `bash` like this: `bash <file>`).
1. when `$execute='1'` (or `-X 1`) the files are executed **directly**, making reXply act as a "launcher" for your applications/scripts (current default).

I recommend you add `#!/bin/bash` hashbang at the top of the file and use `.bash` or `.sh` extension so your text editors also know they are shell executable files - and they keep being properly executed if you enable `$execute`.

## More information

### Terminal

By default, reXply will send the keystroke `Ctrl+Shift+V` to paste commands to terminal (it recognizes `terminal|terminator|tilix|tmux|tilda|guake` in cmdline of active window when it's initialized). If you have customized the paste command to something else in your terminal (e.g.: `Ctrl+V`, like me), you can modify the parameter `$pasteterminal` in `rexply.cfg` file or pass `-P 'command $1'` (where `$1` represents the file holding the processed text).

### dmenu

dmenu dir/file selection menu attaches to the active window when reXply is launched, except in cases it's a terminal (application cmd line contains word `terminal`, `terminator`, `tilix`, `tmux`, `tilda` or `guake`). If your terminal app command line does not contain these words and reXply is not launching dmenu when your terminal is open, search for `guake` in the rexply.bash file and append your terminal binary name to the list (and open an issue in GitHub, please).

### Customize

Script settings can be modified by (in the order it takes precedence):

- passing parameters to `reply` command; or
- modifying the user config file (`$HOME/.rexply/rexply.cfg`); or
- modifying the config file (`rexply.cfg` in rexply.bash's directory); or
- modifying the rexply.bash directly;

## To-do

- [ ] test if everything works in OSX (help wanted)
- [ ] improve textarea fields (the pipe char `|` currently breaks field<->data associations)
- [ ] provide a way to create new files with front-matter headers using the script itself
- [ ] buy more coffee (please donate below!)

## More info regarding the dependencies

- `dmenu` is the standard application used to output information and capture input in OSX due to it's more widespread presence - including availability via Homebrew.
- `xclip` may be substituted with `xsel` (see `$copycmd` option) or `pbcopy` and `pbpaste` - useful in OSX, I just had no time to test yet, so it may need some polishing.
- `xdotool` is used to handle the window focus (and apparently, it's not that easy to make it work on OSX due to `XTEST` not being active by default). You can get rid of this dependency by disabling `$focusit` option. A possible problem if you are using the script to paste data (with `xclip` or `xsel`) while another window is set as _'always-on-top'_: the data will sometimes end up being pasted to the window set as _'always-on-top'_ instead the desired window (depends on the application and other circumstances - not tested on OSX yet).

## OSX

`xdotool` is used to paste in Linux by default. In OSX, the default is **no automatic pasting** and using pbcopy/pbpaste instead (`$pasteit='0'` and `$copycmd='3'`). The processed data should be on your clipboard, just paste it manually after running reXply.

If you want to try automatic pasting, there are 2 ways to implement it:

1. set `$pastedefault='eval cat $1'` and `$pasteterminal='eval cat $1'` (or just pass `-P 'eval cat $1'` parameter) - **note the single quotes** - and pipe reXply to whichever program you want to use to handle the data in sequence. Just as an example, at least theoretically, piping the output to `pbcopy` (e.g.: `rexply -P 'eval cat $1' | pbcopy`) the data will be copied to clipboard (as reXply does by default) and you can paste it manually. I could not test (pbcopy not available in my Linux distro and `xclip`/`xsel` handles input buffer a bit differently). Feel free to try this and other ways to parse the output :)
1. there's another option: disable automatic pasting with `$pasteit='0'` (what is default for OSX) and also set it to keep the _tmpfile_ after processed (`$deltemp='0'` or `-d 0`), then use the processed data saved at _tmpfile_ (by default, `$HOME/rexply/rexply-data/.tmp/tmp`) by your own way.

## Contributing

Feel free to start issues, send pull requests and donate.

## Donate

Help me keep my stuff Open Source and free.

Think on how much time($) you're saving with this tool and buy me some coffee! :)

> USD

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R58RLRMM8YM6U)

> BRL

[![Doar](https://www.paypalobjects.com/pt_BR/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9JMBDY5QA8X5A)
