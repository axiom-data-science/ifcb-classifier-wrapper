FROM alpine:3 as builder

RUN apk --update add openssl wget

RUN wget https://github.com/WHOIGit/ifcb_classifier/archive/refs/tags/v0.3.1.tar.gz && \
    tar -xvzf v0.3.1.tar.gz

FROM mambaorg/micromamba:1.2.0

USER root
COPY --from=builder /ifcb_classifier-0.3.1/ /ifcbnn/
RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER mambauser
COPY --chown=mambauser:mambauser environment.txt /tmp/environment.txt
RUN micromamba install -y -n base -f /tmp/environment.txt && \
    micromamba clean --all --yes 

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip install git+https://github.com/joefutrelle/pyifcb.git

WORKDIR /ifcbnn/
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python"] 