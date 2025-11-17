# Imagen base oficial de Prometheus
FROM prom/prometheus:v2.52.0

# Directorio de trabajo de Prometheus
WORKDIR /etc/prometheus

# Copia el archivo de configuración (importantísimo)
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Copia reglas opcionales si las tenés
# COPY rules.yml /etc/prometheus/rules.yml

# Asegurar permisos (Prometheus corre como root, pero igual aseguramos)
USER root
RUN chown -R nobody:nogroup /etc/prometheus

# Exponer puerto del servidor Prometheus
EXPOSE 9090

# Definir volumen para guardar métricas (persistencia)
VOLUME ["/prometheus"]

# Comando de inicio (no lo sobreescribimos en ECS, acá ya viene default)
ENTRYPOINT [ "/bin/prometheus" ]
CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus" ]
