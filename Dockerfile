FROM mambaorg/micromamba:1.2.0

USER root
RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN git clone --single-branch --branch main https://github.com/WHOIGit/ifcb_classifier.git /ifcbnn

USER mambauser
COPY --chown=mambauser:mambauser environment.txt /tmp/environment.txt
RUN micromamba install -y -n base -f /tmp/environment.txt && \
    micromamba clean --all --yes 

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN pip install git+https://github.com/joefutrelle/pyifcb.git

WORKDIR /ifcbnn/
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python"] 
