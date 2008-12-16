module ApplicationControllerMemberExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def use_cookies_flash
      around_filter do |controller, action|
        action.call
        controller.send(:update_flash_cookies)
      end
    end
  end
  
  module InstanceMethods
    def update_flash_cookies
      unless flash.empty?
        cookies[:flash] = flash.to_json
      end
    end
  end
end