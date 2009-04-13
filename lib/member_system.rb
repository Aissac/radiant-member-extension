module MemberSystem
  
  def self.allow_url?(member, url)
    if url =~ Regexp.new(MemberExtensionSettings.root_path)
      !member.nil?
    else
      true
    end
  end
end