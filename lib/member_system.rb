module MemberSystem
  
  def self.allow_url?(member, url)
    if url =~ /articles/
      !member.nil?
    else
      true
    end
  end
end