# CivicShield - Deployment & Scalability Guide

## Production Deployment Checklist

### Pre-Deployment

- [ ] Change all default passwords
- [ ] Update JWT_SECRET to a strong random value
- [ ] Enable HTTPS/SSL certificates
- [ ] Setup MongoDB Atlas production cluster
- [ ] Configure environment variables for production
- [ ] Run security audit
- [ ] Test all API endpoints
- [ ] Test real-time WebSocket connections

### Heroku Deployment

```bash
# Install Heroku CLI
brew install heroku  # macOS
# or visit https://devcenter.heroku.com/articles/heroku-cli

# Login to Heroku
heroku login

# Create app
heroku create civicshield-prod

# Add MongoDB Atlas
heroku config:set MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/civicshield

# Set environment variables
heroku config:set JWT_SECRET=$(openssl rand -base64 32)
heroku config:set NODE_ENV=production
heroku config:set FRONTEND_URL=https://civicshield-prod.herokuapp.com

# Deploy
git push heroku main

# View logs
heroku logs --tail

# Scale dynos
heroku ps:scale web=2
```

### AWS Deployment (EC2 + RDS)

#### 1. Launch EC2 Instance

```bash
# SSH into instance
ssh -i key.pem ubuntu@ec2-instance-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2

# Install Nginx as reverse proxy
sudo apt install -y nginx

# Clone repository
git clone https://github.com/yourrepo/civicshield.git
cd civicshield
npm install

# Create .env file
sudo nano .env

# Start application with PM2
pm2 start server.js --name civicshield
pm2 startup
pm2 save
```

#### 2. Configure Nginx Reverse Proxy

```nginx
# /etc/nginx/sites-available/civicshield
server {
    listen 80;
    server_name civicshield.example.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:5000/api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/civicshield /etc/nginx/sites-enabled/

# Test Nginx
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

#### 3. Setup HTTPS with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --nginx -d civicshield.example.com

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

#### 4. Setup RDS MongoDB

Use MongoDB Atlas (easier than RDS):
- Create cluster
- Configure IP whitelist
- Get connection string
- Update MONGODB_URI in .env

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Build frontend
WORKDIR /app/frontend
RUN npm ci && npm run build

# Return to root
WORKDIR /app

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5000/api/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start server
CMD ["node", "server.js"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - MONGODB_URI=mongodb://mongo:27017/civicshield
      - JWT_SECRET=${JWT_SECRET}
      - NODE_ENV=production
    depends_on:
      - mongo
    restart: unless-stopped

  mongo:
    image: mongo:5
    volumes:
      - mongo_data:/data/db
    environment:
      - MONGO_INITDB_DATABASE=civicshield
    restart: unless-stopped

volumes:
  mongo_data:
```

Deploy:
```bash
docker-compose up -d
```

### Frontend Deployment (Vercel)

```bash
# Build frontend
cd frontend
npm run build

# Deploy to Vercel
vercel --prod
```

## Scaling Strategies

### Horizontal Scaling

1. **Load Balancing**
   - Use HAProxy or AWS ELB
   - Route traffic across multiple app instances
   - Session affinity for WebSocket connections

2. **Multiple App Instances**
   ```bash
   # Using PM2 cluster mode
   pm2 start server.js -i max
   ```

3. **Database Replication**
   - MongoDB replica set
   - Read replicas for reporting
   - Automatic failover

### Vertical Scaling

- Increase server RAM
- Upgrade CPU cores
- Use faster storage (SSD)

### Caching Layer

```javascript
// Add Redis for caching
import redis from 'redis';

const redisClient = redis.createClient();

// Cache incident queries
app.get('/api/incidents', async (req, res) => {
  const cacheKey = `incidents:${JSON.stringify(req.query)}`;
  const cached = await redisClient.get(cacheKey);
  
  if (cached) {
    return res.json(JSON.parse(cached));
  }
  
  // Fetch from DB and cache
  const incidents = await Incident.find(req.query);
  await redisClient.setEx(cacheKey, 300, JSON.stringify(incidents));
  res.json(incidents);
});
```

### Database Optimization

1. **Indexes**
   ```javascript
   // Ensure indexes on frequently queried fields
   incidentSchema.index({ status: 1 });
   incidentSchema.index({ 'location.lat': 1, 'location.lng': 1 });
   responderSchema.index({ userId: 1 });
   ```

2. **Aggregation Pipeline**
   ```javascript
   // Efficient analytics queries
   await Incident.aggregate([
     { $match: { status: 'resolved' } },
     { $group: { _id: '$type', count: { $sum: 1 } } }
   ]);
   ```

## Monitoring & Observability

### Application Performance

```javascript
// Add monitoring middleware
import prometheus from 'prom-client';

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});

app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

### Logging

```javascript
// Winston logger setup
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Use in application
logger.info('Incident created', { incidentId: incident._id });
```

### Real-time Dashboards

Use services like:
- **DataDog**: Full-stack monitoring
- **New Relic**: APM and infrastructure
- **Grafana**: Custom dashboards
- **ELK Stack**: Centralized logging

## Backup & Disaster Recovery

### MongoDB Backups

```bash
# Manual backup
mongodump --db civicshield --out backup/

# Restore
mongorestore --db civicshield backup/civicshield/

# Atlas automatic backups
# Enable in MongoDB Atlas dashboard
```

### Database Replication

```javascript
// MongoDB replica set configuration
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
});
```

## Performance Optimization

### Response Compression

```javascript
import compression from 'compression';
app.use(compression());
```

### Static Asset Caching

```javascript
app.use(express.static('public', {
  maxAge: '1d',
  etag: false
}));
```

### Database Query Optimization

```javascript
// Use lean() for read-only queries
const incidents = await Incident.find().lean();

// Select only needed fields
const incidents = await Incident.find().select('title status location');

// Pagination
const page = req.query.page || 1;
const limit = req.query.limit || 20;
const skip = (page - 1) * limit;
await Incident.find().skip(skip).limit(limit);
```

## Security Best Practices

- [ ] Use HTTPS everywhere
- [ ] Implement rate limiting
- [ ] Add WAF (Web Application Firewall)
- [ ] Regular security audits
- [ ] Dependency vulnerability scanning
- [ ] Rotate API keys regularly
- [ ] Enable MFA for admin accounts
- [ ] Implement request signing
- [ ] Use environment variables for secrets
- [ ] Enable database encryption at rest

## Cost Optimization

1. **Use spot instances** for non-critical workloads
2. **Auto-scaling** based on demand
3. **CDN caching** for static assets
4. **Database connection pooling**
5. **Scheduled cleanup** of old data
6. **Reserved capacity** for baseline load

## Disaster Recovery Plan

1. **RTO (Recovery Time Objective)**: < 1 hour
2. **RPO (Recovery Point Objective)**: < 15 minutes
3. **Multi-region deployment** for high availability
4. **Regular failover drills**
5. **Automated backups** with retention policy
6. **Incident response playbook**
