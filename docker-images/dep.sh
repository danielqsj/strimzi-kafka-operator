#!/bin/bash
set -e
#set -x
strimzi_version=$RELEASE_VERSION
java_images="java-base"
# Note dependency order of the following images
stunnel_images="stunnel-base zookeeper-stunnel kafka-stunnel entity-operator-stunnel"
kafka_images="kafka-base kafka kafka-connect kafka-mirror-maker zookeeper test-client kafka-connect kafka-connect/s2i"

# Kafka versions
declare -A checksums
checksums["1.0.2"]=4CBCDAF8CCC4EFE3D1B6275F3F2C32CF8F2F1A62104B5DD0BD9E2974160AB89D85A6E1791AF8B948A413B99ED696B06EA9D4299B27EA63C3F7318DABF5761144
checksums["1.1.1"]=2A1EB9A7C8C8337C424EEFED7BAAE26B3DACBA6A4AB8B64D9A7D5C6EE2CDB66CFA76C5B366F23435941569B89BF02482625189016296B2EA2A05FD0F38F6B709
checksums["2.0.0"]=b28e81705e30528f1abb6766e22dfe9dae50b1e1e93330c880928ff7a08e6b38ee71cbfc96ec14369b2dfd24293938702cab422173c8e01955a9d1746ae43f98
checksums["2.0.1"]=9773A85EF2898B4BAE20481DF4CFD5488BD195FFFD700FCC874A9FA55065F6873F2EE12F46D2F6A6CCB5D5A93DDB7DEC19227AEF5D39D4F72B545EC63B24BB2F

function build {
    targets=$@
    # Images not depending on Kafka version
    for image in $(echo "$java_images $stunnel_images"); do
        BUILD_TAG="latest" \
        DOCKER_TAG="$strimzi_version" \
        make -C "$image" "$targets"
    done
    # Images depending on Kafka version (possibly indirectly thru FROM)
    for kafka_version in ${!checksums[@]}; do
        sha=${checksums[$version]}
        for image in $(echo "$kafka_images"); do
            DOCKER_BUILD_ARGS="--build-arg KAFKA_VERSION=${kafka_version} --build-arg KAFKA_SHA512=${sha} ${DOCKER_BUILD_ARGS}" \
            BUILD_TAG="latest" \
            DOCKER_TAG="$strimzi_version-kafka-$kafka_version" \
            makeit make -C "$image" "$targets"
        done
    done
}

build $@