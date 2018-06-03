#!/usr/bin/env bash

CWD=$(pwd)
cd ~/.vim/

echo 🙈 Copying files...

cp ~/.vimrc ~/.vim/
cp ~/.cvsignore ~/.vim/
cp ~/.gitconfig ~/.vim/
cp ~/.bash_profile ~/.vim/
cp ~/.profile ~/.vim/
cp ~/.bashrc ~/.vim/
cp -R ~/.git_template ~/.vim/

echo 🙉 Generating landing script...

echo '#!/usr/bin/env bash
rm -rf ~/.vim/bundle
rm -rf ~/.vim/colors
rm -rf ~/.vim/autoload
echo "🙈  Make dirs..."
mkdir ~/.vim
mkdir ~/.vim/bundle
mkdir ~/.vim/colors
mkdir ~/.vim/autoload
mkdir -p ~/.git_template/hooks
echo "🙉 Clone vim plugins..."' >~/.vim/landing.sh

# the revised first half 
find ~/.vim/bundle/*/.git/config | xargs -n 1 ggrep -Po 'url = \K.*.git' | xargs -n 1 -I {} bash -c 'echo git clone {}' >~/.vim/vvtemppart1
# then create the second half from the first
cat ~/.vim/vvtemppart1 | ggrep -Po '^.*github.com(:|/).+/\K.*(?=\.git)' | xargs -n 1 -I {} bash -c 'echo \~/.vim/bundle/{};' >~/.vim/vvtemppart2
# join em
paste -d " " ~/.vim/vvtemppart1 ~/.vim/vvtemppart2 >>~/.vim/landing.sh
# lazy fix for repos using the ssh link
sed -i .orig "s/git@github.com:/https:\/\/github.com\//g" landing.sh

echo 'echo "🙊 Put things where they belong..."
mv ./autoload/* ~/.vim/autoload/
mv ./.vimrc ~/.vimrc
mv ./.bash_profile ~/.bash_profile
mv ./.profile ~/.profile
mv ./.bashrc ~/.bashrc
mv ./.gitconfig ~/.gitconfig
mv ./.cvsignore ~/.cvsignore
mv ./.git_template/hooks/* ~/.git_template/hooks/
echo "🐒 Done! (make sure git hooks are executable and brew install ctags)"' >> ~/.vim/landing.sh

# clean up
rm ~/.vim/vvtemppart* *.orig

echo 🙊 Git...

git add .vimrc .cvsignore .gitconfig .bash_profile .bashrc landing.sh .profile autoload ./.git_template
git commit -m "auto-update"
git push origin master

# back to where we started
cd $CWD

echo '🐒 Done! '
