# Philips TV version 6 [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Simple%20and%20efficient%20way%20to%20access%20Philips%20TV%20via%20command%20line&url=https://github.com/arzzen/philips-tv&via=arzzen&hashtags=philipstv,philips,stats,tool,developers,rpi,rasppbery)

Tools to control Philips 2016, 2017, 2018 Android TVs via command line.

## Screenshots

One time initialization:
![screenshot from 2018-05-07 12-20-40](https://user-images.githubusercontent.com/6382002/39697398-1c09ab34-51f1-11e8-915a-7bad2f26ec28.png)

Available commands:
![screenshot from 2018-05-07 12-23-19](https://user-images.githubusercontent.com/6382002/39697521-770c3006-51f1-11e8-8ebb-6ac763ec2221.png)

## Usage

```bash
# set tv ip
export _TV_IP="192.168.0.19"
# run command
./tv.sh 
```

Or you can use (non-interactive) direct execution:

`./tv.sh <optional-command-to-execute-directly>`

Possible arguments: 
> allChannels currentChannel channelUp channelDown volume volumeUp volumeDown ambilightConfig ambilightTopology ambilightCache systemInfo getCommand postCommand

#### Custom command

You can set variable `_TV_COMMAND` for send custom command (it will affect: "Send GET command" and "Send POST command" )

```bash
export _TV_COMMAND="ambilight/topology"
```

## Installation

#### Unix like OS

```bash
git clone https://github.com/arzzen/philips-tv.git && cd philips-tv
sudo make install
```

For uninstalling, open up the cloned directory and run

```bash
sudo make uninstall
```

For update/reinstall

```bash
sudo make reinstall
```

#### OS X (homebrew)

@todo

#### Windows (cygwin)

@todo

## System requirements

* Unix like OS with a proper shell
* Tools we use: openssl ; curl ; base64 ; awk ; sed ; tr ; echo ; grep ; cut ; sort ; head ; fold ; uniq ; column.

#### Dependences

* [`jq`](https://github.com/stedolan/jq) `apt install jq`


## Contribution 

Want to contribute? Great! First, read this page.

#### Code reviews
All submissions, including submissions by project members, require review. 
We use Github pull requests for this purpose.

#### Some tips for good pull requests:
* Use our code
  When in doubt, try to stay true to the existing code of the project.
* Write a descriptive commit message. What problem are you solving and what
  are the consequences? Where and what did you test? Some good tips:
  [here](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)
  and [here](https://www.kernel.org/doc/Documentation/SubmittingPatches).
* If your PR consists of multiple commits which are successive improvements /
  fixes to your first commit, consider squashing them into a single commit
  (`git rebase -i`) such that your PR is a single commit on top of the current
  HEAD. This make reviewing the code so much easier, and our history more
  readable.

#### Formatting

This documentation is written using standard [markdown syntax](https://help.github.com/articles/markdown-basics/). Please submit your changes using the same syntax.

## Licensing
MIT see [LICENSE][] for the full license text.

   [read this page]: http://github.com/arzzen/philips-tv/blob/master/docs/CONTRIBUTING.md
   [landing page]: http://arzzen.github.io/philips-tv
   [LICENSE]: https://github.com/arzzen/philips-tv/blob/master/LICENSE
