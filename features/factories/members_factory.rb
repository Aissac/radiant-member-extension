Factory.define :member do |m|
  m.name { Factory.next :name }
  m.email { |m| "#{m.name}@example.com" }
  m.company { Factory.next :company }
end