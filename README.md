```sh
shrc_install() (
  base_url="https://raw.githubusercontent.com/saturday06/dotfiles/master"

  for downloader in \
    "wget --output-document=@file @url" \
    "curl -Lf --output @file @url" \
  ; do
    which `echo $downloader | sed 's/ .*$//'`
    if [ $? -eq 0 ]; then
      break
    fi
    downloader=""
  done

  if [ -z "$downloader" ]; then
    echo downloader not found
    return
  fi

  echo "downloader: $downloader"

  for file in .emacs .shrc; do
    command=`echo $downloader | sed "s%@file%$HOME/$file.shared%" | sed "s%@url%$base_url/$file%"`
    eval $command
  done

  test -e ~/.emacs || echo "(load \"~/.emacs.shared\")" > ~/.emacs
  test -e ~/.zshrc || echo ". ~/.shrc" > ~/.zshrc
  test -e ~/.bashrc || echo ". ~/.shrc" > ~/.bashrc
)

shrc_install
```
