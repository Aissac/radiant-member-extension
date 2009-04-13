require File.dirname(__FILE__) + '/../spec_helper'

describe "Member Tags" do
  
  dataset :pages
  
  before do
    @page = pages(:first)
  end
  
  it "<r:member:login /> renders the login link with default 'Login' text" do
    MemberExtensionSettings.defaults[:login_path] = "/login"
    @page.should render("<r:member:login />").as(%{<a href="/login">Login</a>}) 
  end
  
  it "<r:member:login /> renders the login link with given text" do
    MemberExtensionSettings.defaults[:login_path] = "/login"
    @page.should render("<r:member:login text='Autentificare' />").as(%{<a href="/login">Autentificare</a>}) 
  end
  
  it "<r:member:logout /> renders the logout link with defatul 'Logout' text" do
    @page.should render("<r:member:logout />").as(%{<a href="/logout">Logout</a>})
  end
  
  it "<r:member:logout /> renders the logout link with given text" do
    @page.should render("<r:member:logout text='Iesire din cont' />").as(%{<a href="/logout">Iesire din cont</a>})
  end
  
  it "<r:member:home /> renders the home link for members with default 'Members Home' text" do
    MemberExtensionSettings.defaults[:home_path] = "/home"
    @page.should render("<r:member:home />").as(%{<a href="/home">Members Home</a>})
  end
  
  it "<r:member:home /> renders the home link for members with given text" do
    MemberExtensionSettings.defaults[:home_path] = "/home"
    @page.should render("<r:member:home text='Home of members' />").as(%{<a href="/home">Home of members</a>})
  end
  
  it "<r:member:root /> renders the root link with the default 'Root' text" do
    MemberExtensionSettings.defaults[:root_path] = "/root"
    @page.should render("<r:member:root />").as(%{<a href="/root">Root</a>})
  end
  
  it "<r:member:root /> renders the root link with the given text" do
    MemberExtensionSettings.defaults[:root_path] = "/root"
    @page.should render("<r:member:root text='Radacina' />").as(%{<a href="/root">Radacina</a>})
  end
end