# Monitoring Setup Guide - Grafana + Prometheus

## 🎯 What You Get

- **Grafana** - Beautiful dashboards (http://your-server:3000)
- **Prometheus** - Metrics collection (http://your-server:9090)
- **Node Exporter** - Server metrics (CPU, RAM, Disk)
- **cAdvisor** - Docker container metrics
- **Dozzle** - Real-time logs (http://your-server:8888)

## 🚀 Setup on Server

### 1. Update .env file

```bash
cd /opt/travion
nano .env
```

Add:

```bash
# Grafana credentials
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=YourSecurePassword123
```

### 2. Deploy monitoring stack

```bash
cd /opt/travion
docker compose -f compose/docker-compose.prod.yml up -d prometheus grafana node-exporter cadvisor dozzle
```

### 3. Check status

```bash
docker compose -f compose/docker-compose.prod.yml ps
```

## 🌐 Access Monitoring

### Grafana (Dashboards)

- URL: `http://194.233.89.41:3000`
- Username: `admin`
- Password: (from your .env file)

### Prometheus (Metrics)

- URL: `http://194.233.89.41:9090`
- Targets: http://194.233.89.41:9090/targets

### Dozzle (Logs)

- URL: `http://194.233.89.41:8888`
- No login required

### cAdvisor (Container Stats)

- URL: `http://194.233.89.41:8080`

## 📊 Import Grafana Dashboards

1. Login to Grafana
2. Click + → Import Dashboard
3. Use these IDs:

   - **1860** - Node Exporter Full
   - **193** - Docker Container & Host Metrics
   - **2** - Prometheus Stats

4. Select "Prometheus" as data source

## 🔥 Key Metrics to Monitor

- **CPU Usage** - Should be < 80%
- **Memory Usage** - Should be < 80%
- **Disk Space** - Should be < 80%
- **Container Status** - All should be "Up"
- **Response Time** - Backend latency

## 🔒 Security (Optional)

### Restrict to localhost

Edit compose file ports:

```yaml
ports:
  - "127.0.0.1:3000:3000" # Grafana
  - "127.0.0.1:9090:9090" # Prometheus
```

Then use SSH tunnel:

```bash
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 root@194.233.89.41
```

Access via: http://localhost:3000

## 📈 Next Steps

1. Set up alerts in Grafana
2. Configure notification channels (email, Slack, Discord)
3. Create custom dashboards for your services
4. Monitor application-specific metrics

## 🐛 Troubleshooting

**Can't access Grafana?**

```bash
# Check if running
docker ps | grep grafana

# Check logs
docker logs travion-grafana

# Check firewall
ufw status
ufw allow 3000/tcp
```

**No data in Prometheus?**

- Check targets: http://your-server:9090/targets
- All should be "UP" and green
- Check Prometheus logs: `docker logs travion-prometheus`
