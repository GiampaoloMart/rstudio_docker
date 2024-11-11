# Usa l'immagine ufficiale di RStudio e R
FROM rocker/rstudio:latest

# Aggiorna i pacchetti di sistema e installa le dipendenze necessarie, inclusi Git e librerie per HDF5
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    zlib1g-dev \
    libhdf5-serial-dev \
    hdf5-tools \
    gfortran \
    libpng-dev \
    libjpeg-dev \
    libnetcdf-dev \
    git && \
    rm -rf /var/lib/apt/lists/*

# Imposta variabili d'ambiente per HDF5
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/hdf5/serial/:$LD_LIBRARY_PATH
ENV HDF5_INCLUDE_DIR=/usr/include/hdf5/serial
ENV HDF5_LIB_PATH=/usr/lib/x86_64-linux-gnu/hdf5/serial/

# Installa BiocManager per gestire i pacchetti Bioconductor
RUN R -e "install.packages('BiocManager')"

# Installa devtools per poter installare pacchetti da GitHub
RUN R -e "install.packages('devtools')"

# Installa il pacchetto hdf5r da GitHub
RUN R -e "devtools::install_github('hhoeflin/hdf5r')" && \
    R -e "install.packages(c('tidyverse', 'viridis', 'gghalves', 'cowplot', 'patchwork', 'gridExtra', 'parallel', 'stringi', 'stringr'))"

# Installa i pacchetti Bioconductor
RUN R -e "BiocManager::install(c('Seurat', 'SeuratObject', 'scran', 'scater', 'scDblFinder', 'SoupX', 'BiocGenerics', 'harmony'))"

# Crea un utente per l'accesso a RStudio
RUN useradd -m -s /bin/bash rstudio_user && \
    echo "rstudio_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Assegna la proprietà della directory all'utente rstudio_user
RUN chown -R rstudio_user:rstudio_user /home/rstudio_user

# Espone la porta 8787 per l'accesso a RStudio Server
EXPOSE 8787

# Esegui RStudio come utente rstudio_user
USER rstudio_user

