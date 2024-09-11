#!/bin/bash
# -----------------------------------------------------------------------------
#
# Package	    : cls-bluebird
# Version	    : v2.1.0
# Source repo	    : https://github.com/TimBeyer/cls-bluebird
# Tested on	    : UBI 9.3
# Language          : Node
# Travis-Check      : True
# Script License    : MIT License
# Maintainer	    : Prachi Kurade <prachi.kurade1@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=cls-bluebird
PACKAGE_VERSION=${1:-v2.1.0}
PACKAGE_URL=https://github.com/TimBeyer/cls-bluebird

export NODE_VERSION=${NODE_VERSION:-9}

yum install -y python3 python3-devel.ppc64le git gcc gcc-c++ libffi make cairo

#Installing nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source "$HOME"/.bashrc
echo "installing nodejs $NODE_VERSION"
nvm install "$NODE_VERSION" >/dev/null
nvm use $NODE_VERSION


git clone $PACKAGE_URL $PACKAGE_NAME
cd  $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if ! npm install && npm audit fix --force; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

npm test >> /tmp/TEST.log 2>&1
cat /tmp/TEST.log | grep 'fail'

if [ $? == 0 ]; then
    echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi

