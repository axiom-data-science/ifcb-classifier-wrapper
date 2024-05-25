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
RUN git checkout 3b7f7de210438e1f3a7b451ed51ad6374099e8e9 #2023-06-24
COPY ./patches /tmp/patches
RUN git apply /tmp/patches/*.patch

COPY --chown=$MAMBA_USER:$MAMBA_USER run.py .
ENV TORCH_HOME /tmp/torch
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python", "run.py"]
