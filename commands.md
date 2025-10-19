gpg --import public.key
gpg --allow-secret-key-import --import private.key 

gpg --list-keys

mvn versions:set

#update gradle.properties password
export SONATYPE_USERNAME=
export SONATYPE_PASSWORD=
export GPG_PASSPHRASE=

gradle build
gradle uploadArchives closeAndReleaseRepository -Psigning.password=${GPG_PASSPHRASE}

#build host native lib
./build-libsodium-host.sh
pushd jni
./jnilib.sh
popd
sudo cp ./libsodium/libsodium-host/lib/libsodium.so /usr/lib

mvn clean install -P release-sign-artifacts
mvn clean deploy  -P release-sign-artifacts --settings settings.xml

mvn scm:tag

git tag -a v2.0.1 -m "Version 2.0.1"

gpg --full-generate-key

gpg --armor --export
gpg --armor  --export-secret-keys ID

gpg --keyserver pgp.mit.edu --send-keys
gpg --keyserver keyserver.ubuntu.com --send-keys
gpg --keyserver keys.gnupg.net --send-keys
