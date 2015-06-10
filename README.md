# ka-clone

## The problem
Your devs have both work email addresses and personal ones--and you want to them
to use their work ones for git commits on internal projects. You may also have
common git hooks you wish to use on an organizational level, but the git
security model prevents these from being checked into a repository directly.

Historically, `khan-dotfiles` handles this by setting up a _global git
template_ on the developer's system, which affects all clones. However, since
many of our developers are actively involved in open-source projects outside of
their day jobs, or just want to hack on the KA codebase at home without running
roughshod on their personal computer, this is suboptimal.

## Enter ka-clone
Clones and configures a Khan Academy repository for development, by manipulating
the _local directory_ `.gitconfig` post-checkout.  This enables the user's
global git configuration to remain undisturbed.

## Usage
We can use ka-clone to clone an arbitrary repository:

    $ ka-clone $REPO repo
    Cloning into 'repo'...
    done.
    Configuring your cloned git repository with KA defaults...
    -> Set user.email to fleetwood@khanacademy.org
    -> Added commit-msg linting hook
    -> Linked commit message template
    -> Linked KA gitconfig extras

You can also "upgrade" a repository that is already on your machine to use local
configuration (note also an example of graceful error handling):

    $ cd $MYREPO && ka-clone --repair
    -> Set user.email to fleetwood@khanacademy.org
    -> Added commit-msg linting hook
    *** Commit message template not installed, skipping...
    -> Linked KA gitconfig extras

See the `examples/` directory for more details.

Currently does the following:
- Sets git local `user.email` to work email address (auto-detected)
- Installs khan-linter hook for commit-msg
- Installs optional hooks to protect master branch from commit/push
- Installs an `include` reference to KA global gitconfig "extras"
- Installs the default git commit message template

Everything can be configured via CLI arguments.

```
$ ka-clone --help
usage:
    ka-clone          [options...] <src> [dst]
    ka-clone --repair [options...]


Clones and configures a KA repo.

optional arguments:
  -h, --help            show this help message and exit
  -p, --protect-master  install hooks to protect the master branch
  --repair              attempt to khanify the current directory
  --no-email            do not override user.email
  --no-gitconfig        do not link KA gitconfig extras
  --no-lint             do not hook commit-msg linting
  --no-msg              no commit message template
  --email EMAIL         email address to use (default: mroth@khanacademy.org)
  -q, --quiet           silence success messages
```
