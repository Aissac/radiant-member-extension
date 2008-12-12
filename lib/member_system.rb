module MemberSystem
  
  def self.allow_url?(member, url)
    if url =~ Regexp.new(MEMBERS_ROOT)
      !member.nil?
    else
      true
    end
  end
end