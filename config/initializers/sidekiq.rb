Sidekiq.configure_server do |config|
    config.redis = { url: "rediss://red-cqth782j1k6c738ll0ug:96Mxjt3qPcxmRbaqhMKT2Poltg7RM8CH@oregon-redis.render.com:6379" }
  end
  
  Sidekiq.configure_client do |config|
    config.redis = { url: "rediss://red-cqth782j1k6c738ll0ug:96Mxjt3qPcxmRbaqhMKT2Poltg7RM8CH@oregon-redis.render.com:6379" }
  end
  