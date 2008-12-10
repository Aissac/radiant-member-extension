require 'digest/sha1'

class Member < ActiveRecord::Base
  cattr_accessor :email_name_regex, :domain_head_regex, :domain_tld_regex, :email_regex, :name_regex
  
  self.email_name_regex  = '[\w\.%\+\-]+'.freeze
  self.domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  self.domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  self.email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  self.name_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/
  
  validates_presence_of     :email
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => email_regex

  validates_presence_of     :name
  validates_format_of       :name,     :with => name_regex

  validates_presence_of     :company

  attr_accessor :password
  validates_presence_of     :password,                      :if => :password_required?
  validates_presence_of     :password_confirmation,         :if => :password_required?
  validates_confirmation_of :password,                      :if => :password_required?
  validates_length_of       :password, :within => 4..40,    :if => :password_required?

  before_save :encrypt_password
  before_create :make_activation_code 
  
  attr_accessible :email, :name, :password, :password_confirmation, :company


  %w{name email}.each do |s|
    named_scope :"by_#{s}", lambda{ |search_term| {:conditions => ["LOWER(#{s}) LIKE ?", "%#{search_term.to_s.downcase}%"]}}
  end
  named_scope :by_company, lambda{ |search_term| {:conditions => ["company = ?", search_term] } }
  
  SORT_COLUMNS = ['name', 'email', 'company', 'activation_code', 'emailed_at']

  def self.members_paginate(params)
    options = {
      :page => params[:page],
      :per_page => 10,
    }
    if SORT_COLUMNS.include?(params[:sort_by]) && %w(asc desc).include?(params[:sort_order])
      options[:order] = "#{params[:sort_by]} #{params[:sort_order]}"
    end
    params.reject { |k, v| [:page, :sort_by, :sort_order].include?(k) }.
      inject(Member) { |scope, pair| pair[1].blank? ? scope : scope.send(:"by_#{pair[0]}", pair[1]) }.
      paginate(options)
  end
  
  def self.find_all_group_by_company
     find(:all, :group => 'company')
  end

  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    m = find :first, :conditions => ['email = ? and activation_code IS NULL', email] # need to get the salt
    m && m.authenticated?(password) ? m : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def activate
    self.activation_code = nil
    save(false)
  end
  
  def active?
    activation_code.nil?
  end

protected
  def encrypt_password
    return if password.blank?
    self.salt = make_token if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def encrypt(password)
    password_digest(password, salt)
  end
  
  def password_digest(password, salt)
    digest = REST_AUTH_SITE_KEY
    REST_AUTH_DIGEST_STRETCHES.times do
      digest = secure_digest(digest, salt, password, REST_AUTH_SITE_KEY)
    end
    digest
  end
  
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def make_activation_code
      self.activation_code = make_token
  end
  
  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end

end
