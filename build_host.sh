#!/bin/sh -e

# Use DONTCLEAN=1 ./build_host.sh to avoid rebuilding everything

ROOTDIR="$(pwd)"

CONFIGOPTS="--disable-werror --target-list=x86_64-softmmu"
CILOPTS="--save-temps --noMakeStaticGlobal --useLogicalOperators \
  --useCaseRange"
# XXX -Dcoroutine_fn is useless right now, but we plan to add #ifndef
# XXX in fact no, it's necessary for cpc
GCCOPTS="-U__SSE2__ -w -Dcoroutine_fn='__attribute__((cps))'"
COROOPTS="--load=$ROOTDIR/corocheck/_build/corocheck.cma \
  --doCoroCheck --coopAttr=cps --blockAttr=nocps"

CILBIN="$ROOTDIR/cil/bin/cilly"
CPCBIN="$ROOTDIR/cpc/bin/cpc"

# Make CIL
cd cil
if [ -z "$DONTCLEAN" ]; then
  git clean -fdx
fi
git checkout develop
git pull
./configure
make OCAMLBUILD="ocamlbuild -j 12"

cd ..

# Make CoroCheck
cd corocheck
if [ -z "$DONTCLEAN" ]; then
  git clean -fdx
fi
git checkout master
git pull
# Force clean: fast to build, make sure its consistent with latest CIL
make clean all OCAMLPATH=$ROOTDIR/cil/lib

cd ..

# Make CPC
cd cpc
if [ -z "$DONTCLEAN" ]; then
  git clean -fdx
fi
git checkout develop
git pull
./configure
make

cd ..

# Prepare QEMU
cd qemu
if [ -z "$DONTCLEAN" ]; then
  git clean -fdx
fi
mkdir -p bin/gcc-ucontext
mkdir -p bin/cil-ucontext
mkdir -p bin/cpc-ucontext
mkdir -p bin/cpc-cpc

# Build gcc-ucontext QEMU

# We want to use the same code for all four binaries
git checkout cpc-fixes
git pull

cd bin/gcc-ucontext
../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --extra-cflags="$GCCOPTS"
make -j12 2>&1 | tee make.log

cd ../..

# Build cil-ucontext QEMU (with CoroCheck)

cd bin/cil-ucontext
../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --cc="$CILBIN" \
    --extra-cflags="$GCCOPTS $CILOPTS $COROOPTS" 
make -j12 2>&1 | tee make.log

cd ../..

# Build  cpc-ucontext QEMU

cd bin/cpc-ucontext
../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --cc="$CPCBIN" \
    --extra-cflags="--dontcpc $GCCOPTS $CILOPTS"
make -j12 2>&1 | tee make.log

cd ../..

# Build CPC QEMU

cd bin/cpc-cpc
../../configure $CONFIGOPTS \
    --with-coroutine=cpc    \
    --cc="$CPCBIN" \
    --extra-cflags="$GCCOPTS $CILOPTS"
make -j12 2>&1 | tee make.log

cd ../..

echo Everything built successfully.
