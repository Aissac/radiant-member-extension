require File.dirname(__FILE__) + '/../spec_helper'

describe "Member Tags" do
  
  dataset :pages
  
  before do
    @page = pages(:first)
  end
  
  it "<r:member:login /> renders the login link with default 'Login' text" do
    @page.should render("<r:member:login />").as(%{<a href="#{MEMBER_LOGIN_PATH}">Login</a>}) 
  end
  
  it "<r:member:login /> renders the login link with given text" do
    @page.should render("<r:member:login text='Autentificare' />").as(%{<a href="#{MEMBER_LOGIN_PATH}">Autentificare</a>}) 
  end
  
  it "<r:member:logout /> renders the logout link with defatul 'Logout' text" do
    @page.should render("<r:member:logout />").as(%{<a href="/logout">Logout</a>})
  end
  
  it "<r:member:logout /> renders the logout link with given text" do
    @page.should render("<r:member:logout text='Iesire din cont' />").as(%{<a href="/logout">Iesire din cont</a>})
  end
  
  it "<r:member:home /> renders the home link for members with default 'Members Home' text" do
    @page.should render("<r:member:home />").as(%{<a href="#{MEMBER_HOME_PATH}">Members Home</a>})
  end
  
  it "<r:member:home /> renders the home link for members with given text" do
    @page.should render("<r:member:home text='Home of members' />").as(%{<a href="#{MEMBER_HOME_PATH}">Home of members</a>})
  end
  
  it "<r:member:root /> renders the root link with the default 'Root' text" do
    @page.should render("<r:member:root />").as(%{<a href="#{MEMBERS_ROOT}">Root</a>})
  end
  
  it "<r:member:root /> renders the root link with the given text" do
    @page.should render("<r:member:root text='Radacina' />").as(%{<a href="#{MEMBERS_ROOT}">Radacina</a>})
  end
end