with (import ../nix {});

let

   ndk = androidenv.androidndk_17c.override { fullNDK = true; };
   ndk_root = "${ndk}/libexec/${ndk.name}";

in

mkShell rec {

  LANG="en_US.UTF-8";
  JAVA_HOME=openjdk8;

  ANDROID_SDK_ROOT=builtins.getEnv("HOME") + (if stdenv.isDarwin then "/Library/Android/sdk" else "/Android/Sdk");
  ANDROID_NDK_ROOT="${ANDROID_SDK_ROOT}/ndk-bundle";
  ANDROID_HOME=ANDROID_SDK_ROOT;
  ANDROID_NDK=ANDROID_NDK_ROOT;

  nativeBuildInputs = [
    fastlane
    nodejs-8_x
    openjdk8
  ];

  passthru = { inherit ndk ndk_root; };

  shellHook = ''
    ${./install-ndk-17c.sh} ${ndk} ${ndk_root}
    yes | ${androidenv.androidsdk_9_0}/bin/sdkmanager --licenses --sdk_root="$ANDROID_SDK_ROOT"
    ${lib.optionalString stdenv.isLinux ''
      for dep in lib lib64; do
        if [ -L /$dep ] || [ ! -e /$dep ]; then
          echo "Creating /$dep"
          ln -s ${stdenv.cc.libc}/$dep /$dep
        else
          echo "Using existing /$dep"
        fi
      done
    ''}
  '';
}
