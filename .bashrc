##### PS1 settings
# Colored PS1 with format "username@hostname current-directory-basename (git-branch-name)"

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\u@\h \[\e[32m\]\W \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
