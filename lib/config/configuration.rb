module Config
  class Configuration
    
    def self.reload(server)
      @@host_config = server
      @@cache = YAML::load(File.read('config/configuration.yml'))

      # per-developer configuration only in dev mode
      if (Rails.env == 'development')
        # check if per-developer configuration exists (this is not included in git!!!!!)
        if (File.exist?('config/local_configuration.yml'))
          locale = YAML::load(File.read('config/local_configuration.yml'))

          # copy local -> @@cache without overwrite
          if (locale)
            locale.each do |k1, v1|
              v1.each do |k2, v2|
                v2.each do |k3, v3|
                  @@cache[k1][k2][k3] = v3 if (@@cache[k1] && @@cache[k2] && @@cache[k3])
                end
              end
            end
          end
        end
      end
    end
    
    def self.get(group, name, default="")
      if (@@cache[@@host_config][group.to_s][name.to_s].nil?)
        return default
      else
        return @@cache[@@host_config][group.to_s][name.to_s]
      end
    end
    
    def self.get_root(server)
      return @@cache[server]
    end
    
  end
end