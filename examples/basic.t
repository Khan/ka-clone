SETUP: let us assume a user named fleetwood, and add ka-clone to our PATH:

  $ git init --quiet $CRAMTMP/testrepo
  $ export USER=fleetwood
  $ export REPO=$CRAMTMP/testrepo/.git
  $ export PATH=$TESTDIR/../bin:$PATH

SETUP: we'll also want to mock the HOMEDIR, so we can emulate whether the user
has certain configuration files installed.

  $ mkdir -p $CRAMTMP/home
  $ export HOME=$CRAMTMP/home
  $ mkdir -p $HOME/.git_template
  $ echo "git is fun lol" > $HOME/.git_template/commit_template
  $ echo "[monkey]\n\tking = sun wukong" > $HOME/.gitconfig.khan

--------------------------------------------------------------------------------
We can use ka-clone to clone an arbitrary repository:

  $ ka-clone $REPO repo
  Cloning into 'repo'...
  .* (re)
  done.
  Configuring your cloned git repository with KA defaults...
  -> Set user.email to fleetwood@khanacademy.org
  -> Added commit-msg linting hook
  -> Linked commit message template
  -> Linked KA gitconfig extras

If we descend into the directory, we should see git user email is set locally
to the @khanacademy.org email for the user:

  $ cd repo
  $ git config --local user.email
  fleetwood@khanacademy.org

On top of that, any KA gitconfig extras will be included:

  $ git config --local include.path
  .*/\.gitconfig.khan (re)
  $ git config monkey.king
  sun wukong

Likewise, a git commit-msg hook should be installed for khan-linter:

  $ find .git/hooks -perm -111 -type f ! -name '*.sample'
  .git/hooks/commit-msg

The khan-dotfiles default commit message template is even linked:

  $ git config --local commit.template
  .*/\.git_template/commit_template (re)

We can clone repos in a way that pushing to master is protected:

  $ cd $TMPDIR
  $ ka-clone --protect-master $REPO repo
  Cloning into 'repo'...
  .* (re)
  done.
  Configuring your cloned git repository with KA defaults...
  -> Set user.email to fleetwood@khanacademy.org
  -> Added commit-msg linting hook
  -> Linked commit message template
  -> Linked KA gitconfig extras
  -> Added hooks to protect master branch
  $ cd repo
  $ find .git/hooks -perm -111 -type f ! -name '*.sample'
  .git/hooks/commit-msg
  .git/hooks/pre-commit
  .git/hooks/pre-push
  .git/hooks/pre-rebase

But wait, say you have a repository that has already been cloned, which means
that it probably doesn't have all the tasty goodness...:

  $ cd $TMPDIR
  $ git clone $REPO barerepo 2>/dev/null
  $ cd barerepo
  $ git config --local user.email
  [1]

...Have no fear, you can upgrade it in place!:

  $ ka-clone --repair
  -> Set user.email to fleetwood@khanacademy.org
  -> Added commit-msg linting hook
  -> Linked commit message template
  -> Linked KA gitconfig extras
  $ git config --local user.email
  fleetwood@khanacademy.org
  $ find .git/hooks -perm -111 -type f ! -name '*.sample'
  .git/hooks/commit-msg

Just like a normal git clone, we allow the destination to be inferred:

  $ ka-clone --quiet $REPO
  .* (re)
  $ ls
  testrepo

Allow for repairing hooks in git submodules, which store their GIT_DIR elsewhere:

  $ git init --quiet $CRAMTMP/testsubmodule
  $ (cd $CRAMTMP/testsubmodule && echo "a" > a.txt && git add . && git commit --quiet -m "mock")
  $ git clone --quiet $REPO parentrepo 2>/dev/null
  $ cd parentrepo
  $ git submodule add $CRAMTMP/testsubmodule/.git mysubmodule
  Cloning into 'mysubmodule'...
  done.
  $ cd mysubmodule
  $ ka-clone --protect-master --repair
  -> Set user.email to fleetwood@khanacademy.org
  -> Added commit-msg linting hook
  -> Linked commit message template
  -> Linked KA gitconfig extras
  -> Added hooks to protect master branch
  $ find ../.git/modules/mysubmodule/hooks -perm -111 -type f ! -name '*.sample'
  ../.git/modules/mysubmodule/hooks/commit-msg
  ../.git/modules/mysubmodule/hooks/pre-commit
  ../.git/modules/mysubmodule/hooks/pre-push
  ../.git/modules/mysubmodule/hooks/pre-rebase
