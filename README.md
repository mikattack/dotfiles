# Workbench Configuration

These are **mikattack**'s settings for the Ideal Workflow.  They will not be your ideal, but feel free to use the parts you do like.

I currently work on a Mac, so these directions are fairly specific to that platform.  However, most things should work on the Unix/Linux side of things as well.

## Programs

- iterm2
- vim
- tmux
- [tmuxomatic](https://github.com/oxidane/tmuxomatic)
- [fish](https://fishshell.com/)
- git
- mercurial
- [imapfilter](https://github.com/lefcha/imapfilter)

## Font(s)

- [Inconsolata](http://www.levien.com/type/myfonts/inconsolata.html)
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)

Note that Inconsolata is the font used for text.  Source Code Pro is used for the non-ascii characters in iterm2 (mainly for the vertical pipe character in tmux).

## Colors

Palettes are included when they can be.  However, not all colors can be automatically put into place by the installer.  I've noted instructions for color set up where appropriate.

- Solarized for vim.
- [Monokai Soda](https://github.com/mbadolato/iTerm2-Color-Schemes) for iterm2.
- Default fish colors.
- Hyperlight (modified Monokai) for Sublime Text.
- Custom colors for Taskpaper.

## Keyboard

First: Don't use chiclet or integrated laptop keyboards. Ugh.

I currently use the QWERTY layout with a modified CapsLock key.  The set up may be duplicated as follows:

1. Download [Seil](https://pqrs.org/osx/karabiner/seil.html.en)
2. Download [Karabiner](https://pqrs.org/osx/karabiner/index.html.en)
3. In the **System Preferences->Keyboard** configuration, set the CapsLock key to "No Action".
4. In **Seil** set the CapsLock key to code **59** (left control).
5. In **Karabiner** check the option for:  
     > Control_L to Control_L  
     > (+ When you type Control_L only, send Escape)

