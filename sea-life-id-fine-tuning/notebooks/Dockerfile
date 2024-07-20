FROM tensorflow/tensorflow:2.16.1-gpu-jupyter

RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev

ENV PATH="$PATH:/home/dev/.local/bin"

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/home/dev --ip 0.0.0.0 --no-browser"]
