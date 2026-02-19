FROM postgres:17

RUN apt-get update && \
    apt-get install -y \
        postgresql-17-powa \
        postgresql-17-pg-qualstats \
        postgresql-17-hypopg \
        postgresql-17-pg-stat-kcache \
        postgresql-17-pg-wait-sampling \
        postgresql-17-pg-track-settings \
    && rm -rf /var/lib/apt/lists/*
