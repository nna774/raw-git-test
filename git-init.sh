if [ -e .git ]; then exit -1; fi

mkdir -p .git
echo ref: refs/heads/master > .git/HEAD

mkdir -p .git/objects
mkdir -p .git/objects/info
mkdir -p .git/objects/pack
mkdir -p .git/refs
mkdir -p .git/refs/heads
mkdir -p .git/refs/tags
