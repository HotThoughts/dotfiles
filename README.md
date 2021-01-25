# Dotfiles

The best practice of syncing dotfiles, follows the article [How to manage your dotfiles with git](https://medium.com/toutsbrasil/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b).
> No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.


## Sync dotfiles in a new computer
- Clone the bare repo to the new computer home directory
`git clone --bare https://github.com/USERNAME/dotfiles.git ~/.dotfiles`
- Add alias to `.bashrc` or `.zshrc` so that you can use `dotfiles` as `git`
`alias dotfiles='/usr/bin/git --git-dir=~/.dotfiles/ --work-tree=~'`
- Checkout repo
`dotfiles checkout`

##  Useage
Same as `git`, we can use, for example
- `dotfiles add .zshrc` to add changes to stage
- `dotfiles commit -m "message"` to commit
- `dotfiles push` to push commit to GitHub
- ...


👾 Happy configurations!
