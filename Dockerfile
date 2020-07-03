# parameters
ARG REPO_NAME="<REPO_NAME_HERE>"
ARG MAINTAINER="<YOUR_FULL_NAME> (<YOUR_EMAIL_ADDRESS>)"

# ==================================================>
# ==> Do not change the code below this line
ARG ARCH=arm32v7
ARG MAJOR=daffy
ARG BASE_TAG=${MAJOR}-${ARCH}
ARG BASE_IMAGE=dt-commons

# define base image
FROM duckietown/${BASE_IMAGE}:${BASE_TAG}

# recall all arguments
ARG ARCH
ARG MAJOR
ARG REPO_NAME
ARG MAINTAINER
ARG BASE_TAG
ARG BASE_IMAGE

# keep some arguments as environment variables
ENV DT_MODULE_TYPE "${REPO_NAME}"
ENV DT_MAINTAINER "${MAINTAINER}"

# check build arguments
RUN /utils/build_check "${REPO_NAME}" "${MAINTAINER}"

# define/create repository path
ARG REPO_PATH="${SOURCE_DIR}/${REPO_NAME}"
ARG LAUNCH_PATH="${LAUNCH_DIR}/${REPO_NAME}"
RUN mkdir -p "${REPO_PATH}"
RUN mkdir -p "${LAUNCH_PATH}"
ENV DT_REPO_PATH "${REPO_PATH}"
ENV DT_LAUNCH_PATH "${LAUNCH_PATH}"
WORKDIR "${REPO_PATH}"

# install apt dependencies
COPY ./dependencies-apt.txt "${REPO_PATH}/"
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    $(awk -F: '/^[^#]/ { print $1 }' dependencies-apt.txt | uniq) \
  && rm -rf /var/lib/apt/lists/*

# install python dependencies
COPY ./dependencies-py3.txt "${REPO_PATH}/"
RUN pip3 install -r ${REPO_PATH}/dependencies-py3.txt

# copy the source code
COPY ./packages/. "${REPO_PATH}/"

# install launcher scripts
COPY ./launchers/* "${LAUNCH_PATH}/"
COPY ./launchers/default.sh "${LAUNCH_PATH}/"
RUN /utils/install_launchers "${LAUNCH_PATH}"

# store module metadata
LABEL org.duckietown.label.module.type="${REPO_NAME}" \
    org.duckietown.label.architecture="${ARCH}" \
    org.duckietown.label.code.location="${REPO_PATH}" \
    org.duckietown.label.base.major="${MAJOR}" \
    org.duckietown.label.base.image="${BASE_IMAGE}" \
    org.duckietown.label.base.tag="${BASE_TAG}" \
    org.duckietown.label.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================
