class MemberExtensionSettings
  
  class MissingSettingError < StandardError; end

  @@soft_keys     = [:login_path, :home_path, :root_path]
  @@hard_keys     = [:logout_path, :sessions_path, :rest_auth_digest_stretches]
  @@required_keys = [:rest_auth_site_key]
  
  @@all_keys = (@@soft_keys + @@hard_keys + @@required_keys).uniq

  @@defaults = {
    :login_path                 => "/login",   # The URL for the login form of your website.
    :home_path                  => "/members", # Members will be redirected here on successful login.
    :root_path                  => "members",  # Everything under this path requires member login.
    :logout_path                => "/logout",
    :sessions_path              => "member_sessions",
    :rest_auth_digest_stretches => 10
  }

  cattr_accessor :defaults, :hard_keys, :soft_keys, :required_keys, :all_keys
  
  (@@hard_keys + @@required_keys).uniq.each { |key| attr_accessor key }
  
  def self.instance
    @@instance ||= new
  end
  
  (class << self; self; end).instance_eval do
    MemberExtensionSettings.all_keys.each do |att|
      define_method att do
        MemberExtensionSettings.instance.send(att)
      end
    end
  end
  
  @@soft_keys.each do |key|
    define_method key do
      Radiant::Config["Member.#{key}"] || defaults[key]
    end
  end
  
  def self.check!
    required_keys.each do |key|
      raise MissingSettingError.new("You must set MemberExtensionSettings.defaults[:#{key}] in config/initializers/member.rb") unless self.send(key)
    end
  end
   
  def config
    @config
  end
  
    def initialize      
      (hard_keys + required_keys).each do |key|
        self.send(:"#{key}=", defaults[key])
      end
    end  

end
