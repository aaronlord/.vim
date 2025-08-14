> As an engineer, there is a short list of tools that you must be rabid about. Rabid. Foaming at the mouth crazy.
>
> -- <cite>[Michael Lopp][1]</cite>

### Installation

Install [Neovim](https://github.com/neovim/neovim).

```
$ cd ~
$ git clone https://github.com/aaronlord/.vim.git
$ rm -rf ~/.config/nvim
$ ln -s ~/.vim ~/.config/nvim
$ nvim
```

Be sure to run `:checkhealth` dependancy issues (node, python, php, etc).

### LSP

I use the default LSP client that comes with Neovim, therefore I have stuck
to the default keybindings:

```
ctrl-]          -> go to definition
gq              -> format selected text or text object
K               -> display documentation of the symbol under the cursor
ctrl-x + ctrl-o -> in insert mode, trigger code completion
grn             -> renames all references of the symbol under the cursor
gra             -> list code actions available in the line under the cursor
grr             -> lists all the references of the symbol under the cursor
gri             -> lists all the implementations for the symbol under the cursor
gO              -> lists all symbols in the current buffer
ctrl-s          -> in insert mode, display function signature under the cursor
[d              -> jump to previous diagnostic in the current buffer
]d              -> jump to next diagnostic in the current buffer
ctrl-w + d      -> show error/warning message in the line under the cursor
```

[1]:http://www.randsinrepose.com/archives/2009/11/02/the_foamy_rules_for_rabid_tools.html
