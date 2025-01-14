FROM python:3.9-slim@sha256:3e45d072301981add6ab1d376394edc4eb0ec2afb70e7ffcbb3113eb432ab709

RUN mkdir -p /app
WORKDIR /app

COPY requirements.txt .

RUN	apt-get update							\
     && apt-get install -y git gcc g++ make python3-dev swig		\
     && apt-get install -y jq awscli curl				\
     && apt-get install -y libsodium23   libsecp256k1-0   libgmp10	\
     && apt-get install -y libsodium-dev libsecp256k1-dev libgmp-dev	\
     && pip --no-cache install -r ./requirements.txt			\
     && cd /tmp								\
     && git clone https://github.com/tacoinfra/libhsm			\
     && cd libhsm/build							\
     && ./build_libhsm							\
     && cp libhsm.so /usr/lib/x86_64-linux-gnu/libhsm.so		\
     && cd /								\
     && rm -rf /tmp/libhsm						\
     && apt-get purge -y git gcc g++ make python3-dev swig		\
     && apt-get purge -y libsodium-dev libsecp256k1-dev libgmp-dev	\
     && apt-get autoremove -y						\
     && rm -rf /var/lib/apt /var/cache/apt /root/.cache \
     && rm -rf __pycache__
#
# We do not install the dependencies for the following packages because
# we use only a subset of their functionality and the dependencies are
# not necesary for us.
#
# XXXrcd: We should fetch a particular version of these libraries.
#
# XXXrcd: in future we might only install the .so because we only use
#         the "configure" command which just manipulates a little JSON.

RUN	TOP=https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient	\
	VER=Bionic							\
	PKCS11=cloudhsm-pkcs11_latest_u18.04_amd64.deb;			\
									\
	set -e;								\
									\
	curl -s -o "$PKCS11" "$TOP/$VER/$PKCS11";			\
	dpkg -i --force-depends "$PKCS11";				\
	rm -f "$PKCS11"

ARG FLASK_ENV=production
ENV FLASK_ENV=$FLASK_ENV

RUN groupadd -r -g 999 remotesigner && \
  useradd -r -u 999 -g remotesigner remotesigner

COPY src ./src
COPY entrypoint.sh ./
COPY hsm-remote-signer.sh ./
COPY signer.py ./

# Make files un-writeable
RUN rm -rf /usr/local/bin/pip \
    && rm requirements.txt \
    && chown -R remotesigner:remotesigner . \
    && chmod 540 entrypoint.sh hsm-remote-signer.sh signer.py \
    && chmod -R 540 src \
    && chmod 770 .

USER 999

ENTRYPOINT ["./entrypoint.sh"]
