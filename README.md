<a href="https://gitmoji.dev">
  <img src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat-square" alt="Gitmoji">
</a>

# Dotfiles

The best practice of syncing dotfiles, follows the article [How to manage your dotfiles with git](https://medium.com/toutsbrasil/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b).
> No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.


## Sync dotfiles in a new computer
- Setup your dotfile repo, and clone the bare repo to the new computer home directory
```sh
git clone --bare https://github.com/<YOUR USERNAME>/dotfiles.git ~/.dotfiles
```

- Add alias to `.bashrc`, `.zshrc` or `config.fish` so that you can use `dotfiles` as `git`
  #### fish
  ```sh
  alias -s dotfiles "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
  ```
  #### zsh
  ```sh
  alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
  ```

- Checkout repo
```sh
dotfiles checkout
```

- Ignore untracked files
```sh
dotfiles config --local status.showUntrackedFiles no
```

##  Useage
Same as `git`, we can use, for example
- add changes to stage
```sh
dotfiles add .zshrc
```

- commit
```sh
dotfiles commit -m "message"
```

- push commit to your remote repo
```sh
dotfiles push
```

- ...


👾 Happy configurations!
