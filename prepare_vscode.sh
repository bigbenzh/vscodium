#!/bin/bash

set -e

cp -rp src/* vscode/
cp -f LICENSE vscode/LICENSE.txt

cd vscode || exit

../update_settings.sh

# apply patches
{ set +x; } 2>/dev/null

for file in ../patches/*.patch; do
  if [ -f "$file" ]; then
    echo applying patch: $file;
    git apply --ignore-whitespace "$file"
    if [ $? -ne 0 ]; then
      echo failed to apply patch $file 1>&2
    fi
  fi
done

for file in ../patches/user/*.patch; do
  if [ -f "$file" ]; then
    echo applying user patch: $file;
    git apply --ignore-whitespace "$file"
    if [ $? -ne 0 ]; then
      echo failed to apply patch $file 1>&2
    fi
  fi
done

set -x

if [[ "$OS_NAME" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile --ignore-optional
  npm_config_argv='{"original":["--ignore-optional"]}' yarn postinstall
else
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile
fi

mv product.json product.json.bak


# set fields in product.json


cat product.json.bak > product.json

../undo_telemetry.sh

if [[ "$OS_NAME" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://vscodium.com/img/vscodium.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|Microsoft Corporation|VSCodium Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|VSCodium|'  resources/linux/rpm/code.spec.template
fi

cd ..
