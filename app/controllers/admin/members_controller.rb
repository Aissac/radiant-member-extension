class Admin::MembersController < ApplicationController

  require 'fastercsv'

  LIST_PARAMS_BASE = [:page, :sort_by, :sort_order]
  FILTER_COLUMNS = [:name, :email, :company]
  before_filter :add_member_assets

  skip_before_filter :verify_authenticity_token, :only => 'auto_complete_for_member_company'
  auto_complete_for :member, :company
  
  def index
    @companies = Member.find_all_group_by_company
    filter_by_params(FILTER_COLUMNS)
    @members = Member.members_paginate(list_params)
  end

  def new
    @member = Member.new
  end
 
  def create
    @member = Member.new(params[:member])
    if @member.save
      redirect_to members_path
      flash[:notice] = "Account created."
    else
      flash[:error]  = "Account not created."
      render :action => 'new'
    end
  end
  
  def edit
    @member = Member.find(params[:id])
  end
  
  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member]) 
      redirect_to members_path
      flash[:notice] = "Account edited."
    else
      flash[:error]  = "Account not edited."
      render :action => 'edit'
    end
  end
  
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    flash[:notice] = "Member deleted!"
    redirect_to members_path
  end
  
  def activate
    @member = Member.find(params[:id])
    @member.activate!
    flash[:notice] = "Member #{@member.name} has been activated!"
    redirect_to members_path
  end
  
  def deactivate
    @member = Member.find(params[:id])
    @member.deactivate!
    flash[:notice] = "Member #{@member.name} has been deactivated!"
    redirect_to members_path
  end
  
  def reset_password
    @member = Member.find(params[:id])
  end
  
  def send_email
    @member = Member.find(params[:id])
    @member.email_new_password
    flash[:notice] = "The password for #{@member.name} was reset and sent via email."
    redirect_to('/admin/members')
  end
  
  def import
  end
  
  def import_from_csv
    imported, duplicate, @not_valid = Member.import_members(params[:file][:csv])    
    flash[:notice] = "Imported #{imported} members. " + "#{duplicate} members were duplicate."
    @not_valid.empty? ? (redirect_to members_path) : (render :action => 'edit_invalid')
  end
  
  def edit_invalid
  end
  
  def update_invalid
    imported, @not_valid = Member.update_invalid_members(params[:member])
    flash[:notice] = "Imported #{imported} members."
    @not_valid.empty? ? (redirect_to members_path) : (render :action => 'edit_invalid')
  end
  
  def list_params
    @list_params ||= {}
  end
  helper_method :list_params
  
  protected
    def filter_by_params(args)
      args = args + LIST_PARAMS_BASE
      args.each do |arg|
        list_params[arg] = params[:reset] ? params[arg] : params[arg] || cookies[arg]
      end
      list_params[:page] ||= "1"
    
      update_list_params_cookies(args)
    
      # pentru will_paginate
      params[:page] = list_params[:page]
    end
  
    def update_list_params_cookies(args)
      args.each do |key|
        cookies[key] = { :value => list_params[key], :path => "/#{controller_path}" }
      end
    end
    
    def add_member_assets
      include_stylesheet 'admin/member'
      include_javascript 'admin/controls'
    end
end