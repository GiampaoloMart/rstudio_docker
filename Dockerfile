# Usa l'immagine ufficiale di RStudio e R
FROM rocker/rstudio:latest

# Aggiorna i pacchetti di sistema e installa le dipendenze necessarie per hdf5r
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libhdf5-dev \
    zlib1g-dev \
    libhdf5-serial-dev \
    hdf5-tools && \
    rm -rf /var/lib/apt/lists/*

# Installa BiocManager per gestire i pacchetti Bioconductor
RUN R -e "install.packages('BiocManager')"

# Installa i pacchetti CRAN, incluso hdf5r
RUN R -e "install.packages(c('tidyverse', 'viridis', 'gghalves', 'cowplot', 'patchwork', 'gridExtra', 'hdf5r', 'parallel', 'stringi', 'stringr'))"

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
