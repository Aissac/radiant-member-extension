class Admin::MembersController < ApplicationController

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
      flash[:notice] = "Account created"
    else
      flash.now[:error]  = "Account not created"
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
      flash[:notice] = "Account edited"
    else
      flash.now[:error]  = "Account not edited"
      render :action => 'edit'
    end
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
      include_javascript 'controls'
    end
end
