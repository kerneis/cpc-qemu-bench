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
# We want to use the same code for all four binaries
git checkout cpc-fixes
git pull

for nopool in "" "-nopool"; do

  if [ "$nopool" = "-nopool" ]; then
    GCCOPTS="$GCCOPTS -DNO_COROUTINE_POOL"
  fi

  mkdir -p bin/gcc-ucontext${nopool}
  mkdir -p bin/cil-ucontext${nopool}
  mkdir -p bin/cpc-ucontext${nopool}
  mkdir -p bin/cpc-cpc${nopool}

  # Build gcc-ucontext QEMU

  cd bin/gcc-ucontext${nopool}
  ../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --extra-cflags="$GCCOPTS"
  make -j8 > make.log 2>&1 

  cd ../..

  # Build cil-ucontext QEMU (with CoroCheck)

  cd bin/cil-ucontext${nopool}
  ../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --cc="$CILBIN" \
    --extra-cflags="$GCCOPTS $CILOPTS $COROOPTS" 
  make -j8 > make.log 2>&1 

  cd ../..

  # Build  cpc-ucontext QEMU

  cd bin/cpc-ucontext${nopool}
  ../../configure $CONFIGOPTS \
    --with-coroutine=ucontext    \
    --cc="$CPCBIN" \
    --extra-cflags="--dontcpc $GCCOPTS $CILOPTS"
  make -j8 > make.log 2>&1 

  cd ../..

  # Build CPC QEMU

  cd bin/cpc-cpc${nopool}
  ../../configure $CONFIGOPTS \
    --with-coroutine=cpc    \
    --cc="$CPCBIN" \
    --extra-cflags="$GCCOPTS $CILOPTS"
  make -j8 > make.log 2>&1 

  cd ../..

done

echo Everything built successfully.
