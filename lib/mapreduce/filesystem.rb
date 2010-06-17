module MapRedus
  # Manages the book keeping of redis keys and redis usage
  # provides the data storage for job information through redis
  # All interaction with redis should go through this class
  # 
  class FileSystem
    def self.storage
      MapRedus.redis
    end
    
    # Save/Read functions to save/read values for a redis key
    #
    # Examples
    #   FileSystem.save( key, value ) 
    def self.save(key, value)
      storage.set(key, value)
    end

    def self.save_temporary(key, value, time = 3600)
      save(key, value)
      storage.expire(key)
    end

    def self.method_missing(method, *args, &block)
      storage.send(method, *args)
    end
    
    # Setup locks on results using RedisSupport lock functionality
    #
    # Examples
    #   FileSystem::has_lock?(keyname)
    #   # => true or false 
    #
    # Returns true if there's a lock
    def self.has_lock?(keyname)
      MapRedus.has_redis_lock?( RedisKey.result_custom_key(keyname) ) 
    end
    
    def self.acquire_lock(keyname)
      MapRedus.acquire_redis_lock_nonblock( RedisKey.result_custom_key(keyname), 60 * 60 )
    end
    
    def self.release_lock(keyname)
      MapRedus.release_redis_lock( RedisKey.result_custom_key(keyname) )
    end
  end
end