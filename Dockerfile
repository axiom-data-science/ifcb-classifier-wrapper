FROM mambaorg/micromamba:1.5.8

USER root
RUN apt-get update && apt-get install -y git wget && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER mambauser
COPY --chown=mambauser:mambauser environment.txt /tmp/environment.txt
RUN micromamba install -y -n base -f /tmp/environment.txt && \
    micromamba clean --all --yes 

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip install git+https://github.com/joefutrelle/pyifcb.git@d00f6aa

WORKDIR /ifcbnn/
ARG ifcb_classifier_cache_bust=1
RUN git clone --single-branch --branch main https://github.com/WHOIGit/ifcb_classifier.git .
COPY ./patches /tmp/patches
RUN git apply /tmp/patches/*.patch

COPY --chown=$MAMBA_USER:$MAMBA_USER run.py .
ENV TORCH_HOME /tmp/torch
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python", "run.py"]
