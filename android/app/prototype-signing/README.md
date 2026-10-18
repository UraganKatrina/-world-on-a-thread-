# Prototype signing key

`prototype.jks` signs test APKs built by CI so that each new build installs
over the previous one. It is committed on purpose and therefore **public**:
never use it for Google Play or any real release.

For a real release, create a private key and a `android/key.properties`
(not committed) with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.
When that file exists, the build uses it instead of this key.
