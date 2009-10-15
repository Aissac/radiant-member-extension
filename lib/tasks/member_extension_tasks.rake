namespace :radiant do
  namespace :extensions do
    namespace :member do
      
      desc "Runs the migration of the Member extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          MemberExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          MemberExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Member to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from MemberExtension"
        Dir[MemberExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(MemberExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
