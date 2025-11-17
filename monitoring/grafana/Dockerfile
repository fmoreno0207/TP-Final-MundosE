# FROM grafana/grafana:latest
# COPY provisioning /etc/grafana/provisioning


# # Asegurar permisos y path correcto
# USER root
# RUN chmod -R 755 /etc/grafana/provisioning
# Imagen oficial de Grafana
FROM grafana/grafana:12.2.1

# Directorio de trabajo
WORKDIR /etc/grafana

# Copia provisioning (dashboards + datasources)
# Debe existir grafana/provisioning con la estructura correcta
COPY provisioning /etc/grafana/provisioning

# Copia archivos de configuración adicionales si los tuvieras
# COPY grafana.ini /etc/grafana/grafana.ini

# Asegura permisos correctos para que el usuario "grafana" pueda leerlos
USER root
RUN chown -R grafana:grafana /etc/grafana/provisioning

# Plugins opcionales (si quieres agregar más)
# ENV GF_INSTALL_PLUGINS="grafana-clock-panel,grafana-piechart-panel"

# Expone el puerto que definiste en ECS (9500)
EXPOSE 9500

# Configura Grafana para usar el puerto 9500 en AWS ECS Fargate
ENV GF_SERVER_HTTP_PORT=9500

# Vuelve a usuario no-root para seguridad
USER grafana

# Inicia Grafana
ENTRYPOINT ["/run.sh"]
