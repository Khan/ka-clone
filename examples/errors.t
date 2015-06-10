SETUP: let us assume a user named fleetwood, and add ka-clone to our PATH:

  $ git init --quiet $CRAMTMP/testrepo
  $ export USER=fleetwood
  $ export REPO=$CRAMTMP/testrepo/.git
  $ export PATH=$PATH:$TESTDIR/../bin

SETUP: we'll also want to mock the HOMEDIR, so we can emulate whether the user
has certain configuration files installed.

  $ mkdir -p $CRAMTMP/home
  $ export HOME=$CRAMTMP/home
  $ mkdir -p $HOME/.git_template
  $ echo "git is fun lol" > $HOME/.git_template/commit_template
  $ echo "[monkey]\n\tking = sun wukong" > $HOME/.gitconfig.khan

--------------------------------------------------------------------------------
Using ka-clone from a nonexistent source should throw an intelligent error:

  $ ka-clone /tmp/nopenopedoesntexist foo
  fatal: repository '/tmp/nopenopedoesntexist' does not exist
  [128]

One can't repair a directory which isn't a git repository:

  $ ka-clone --repair
  fatal: Not a git repository (or any of the parent directories): .git
  [128]

If the user doesn't have certain global config files from khan-dotfiles, warn
we can't link them but proceed gracefully:

  $ rm $HOME/.git_template/commit_template
  $ rm $HOME/.gitconfig.khan
  $ ka-clone $REPO repo
  Cloning into 'repo'...
  .* (re)
  done.
  Configuring your cloned git repository with KA defaults...
  -> Set user.email to fleetwood@khanacademy.org
  -> Added commit-msg linting hook
  *** Commit message template not installed, skipping...
  *** KA gitconfig extras not installed, skipping...

(Referencing these "legacy" configs rather than bundling is an intentional
design decision, so those config files can continue to be updated as they have
in the past, and existing global configurations will work--hence better reverse
compatibility. Also, the user can find them to manually modify somewhere they
might expect if they are old-school.)
